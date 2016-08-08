require 'pdf-reader'
require 'xml'
require 'tmpdir'
require 'tempfile'

filename = ARGV[0]

path = File.dirname( File.absolute_path(filename) )

Dir.mktmpdir {|dir|
  
puts `mutool draw -r 304.8 -o #{dir}/page%03d.png #{filename}`

reader = PDF::Reader.new(filename)

doc = reader

$objects = doc.objects

def is_note?(object)
  object[:Type] == :Annot && [:Text, :FreeText].include?(object[:Subtype])
end

def is_markup?(object)
  object[:Type] == :Annot && [:Highlight, :Underline].include?(object[:Subtype])
end

def annots_on_page(page)
  references = (page.attributes[:Annots] || [])
  lookup_all(references).flatten
end

def lookup_all(refs)
  refs = *refs
  refs.map { |ref| lookup(ref) }
end

def lookup(ref)
  object = $objects[ref]
  return object unless object.is_a?(Array)
  lookup_all(object)
end

def notes_on_page(page)
  all_annots = annots_on_page(page)
  all_annots.select { |a| is_note?(a) }
end

def markups_on_page(page)
  all_annots = annots_on_page(page)
  markups = all_annots.select { |a| is_markup?(a) }.map {|a| Markup.new(a) }

  if markups.any?
    receiver = MarkupReceiver.new(markups)
    page.walk(receiver)
    coords = nil
    receiver.set_markup_texts
  end
  markups

end

audio = {}

reader.pages.each do |page|
  audio[page.number] ||= []
  
  for annot in annots_on_page(page)
    if annot[:T] == "Audio"
      audio[page.number] << annot[:Contents]
    end
  end
end


#f = File.open("editlist.xml","w")
f = Tempfile.new(["editlist",".xml"])

f.puts "<mlt>"

for page in reader.pages
  f.puts "  <producer id=\"page#{page.number}-source\">"
  f.puts "    <property name=\"resource\">#{dir}/page#{'%03d' % page.number}.png</property>"
  f.puts "  </producer>"

f.puts <<EOF
    <tractor id="page#{page.number}">
       <multitrack>
         <track producer="page#{page.number}-source"/>
       </multitrack>
EOF

  f.puts "    </tractor>"
end

################################################################
# add producers for extra audio tracks

for page in reader.pages
  if audio[page.number].length > 0
    f.puts <<EOF
  <producer id="page#{page.number}-audio">
    <property name="resource">#{File.join( path, audio[page.number].first )}</property>
    <property name="normalise"></property>
  </producer>
EOF
  end
end

################################################################
# write main playlist, storing starting frames along the way

playlist = "main-playlist"
f.puts "  <playlist id=\"#{playlist}\">"

scene_start = 0
starts = {}

for page in reader.pages

  cut_in = 0
  cut_out = 30
  
  if audio[page.number].length > 0
    melted = `melt #{audio[page.number].first} -consumer xml`
    parser = XML::Parser.string(melted)
    doc = parser.parse
    frame_rate_num = doc.find('profile')[0]['frame_rate_num'].to_i
    frame_rate_den = doc.find('profile')[0]['frame_rate_den'].to_i
    frame_rate = frame_rate_num.to_f / frame_rate_den.to_f
    puts frame_rate
    cut_in = doc.find('tractor')[0]['in'].to_i
    cut_out = doc.find('tractor')[0]['out'].to_i

    cut_in = (cut_in * frame_rate)
    cut_out = (cut_out * frame_rate)

    cut_in = (cut_in / 30.0).floor
    cut_out = (cut_out / 30.0).ceil
  end

  starts[page.number] = scene_start

  scene_length = cut_out - cut_in
  scene_start = scene_start + scene_length    

  f.puts "    <entry producer=\"page#{page.number}\" in=\"#{cut_in}\" out=\"#{cut_out}\"/>"
end

f.puts "  </playlist>"

total_frames = scene_start

################################################################
# make playlists to mix together the extra audio tracks

for page in reader.pages
  if audio[page.number].length > 0
    f.puts <<EOF
  <playlist id="page#{page.number}-audio-playlist">
    <blank length="#{starts[page.number]}"/>
    <entry producer="page#{page.number}-audio" out="#{total_frames - starts[page.number]}"/>
  </playlist>

  <tractor id="#{playlist}-mix">
    <multitrack>
      <track producer="#{playlist}"/>
      <track producer="page#{page.number}-audio-playlist"/>
    </multitrack>
    <transition id="transition-#{playlist}" out="#{total_frames}">
      <property name="a_track">0</property>
      <property name="b_track">1</property>
      <property name="mlt_type">transition</property>
      <property name="mlt_service">mix</property>
    </transition>
  </tractor>
EOF

    playlist = playlist + "-mix"
  end
end

f.puts "</mlt>"
f.close

puts audio


`melt #{f.path} -profile atsc_1080p_30 -consumer avformat:dump.mp4 acodec=libmp3lame vcodec=libx264`

}
