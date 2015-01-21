require "wing/version"

require "fileutils"
require "yaml"
require "shellwords"

module Wing
  TEMPLATES = File.expand_path("../wing/templates", __FILE__)
  ASSETS    = File.expand_path("../wing/assets", __FILE__)
  SCRIPTS   = File.expand_path("../wing/scripts", __FILE__)

  def self.run(argv)
    files = if argv.size > 1
              argv.drop(1)
            else
              Dir.glob("**/*.md")
            end

    case argv[0]
    when "init"
      init
    when "html"
      Generator.new(files).gen_html
    when "gen"
      Generator.new(files).gen_pdf
    else
      help
    end
  end

  def self.help
    puts <<-EOS
Usage: wing [init|gen] [OPTIONS] [FILES]
    EOS
  end

  def self.init
    FileUtils.cp File.join(TEMPLATES, "config.yml"), "config.yml"
    FileUtils.cp File.join(TEMPLATES, "gitignore"), ".gitignore"
  end

  class Config < Struct.new(:title, :author, :files)
    def self.load(content)
      data = YAML.load(content)
      new(
        data["title"],
        data["author"],
        data["files"]
      )
    end
  end


  class Generator
    def initialize(files)
      @files = files
    end

    def config
      @config ||= if File.exists?("config.yml")
        Config.load(File.read("config.yml"))
      else
        Config.new
      end
    end


    def gen_pdf
      prepare
      gen_html

      # Convert to pdf
      system "phantomjs #{phantom_script_path} file://#{@html_path} #{Shellwords.escape(title)}.pdf A4"
      puts "#{title}.pdf generated"
    end

    def gen_html
      # Write html to file
      @html_path = File.expand_path(File.join("build", "page.html"))
      File.open(@html_path, "w") {|f| f.write html }
    end

    def prepare
      # Prepare build dir
      FileUtils.rm_r "build" if File.exists?("build")
      FileUtils.mkdir_p "build"

      # Copy assets
      FileUtils.cp_r ASSETS, File.join("build", "assets")
    end


    def phantom_script_path
      File.join(SCRIPTS, "rasterize.js")
    end

    def files
      config.files || @files
    end

    def title
      config.title || files.first
    end

    def body
      require "github/markdown"

      GitHub::Markdown.to_html(content, :markdown) do |code, lang|
        if lang == "diagram"
          %Q|<div class="mermaid">\n#{code}\n</div>\n|
        end
      end
    end

    def content
      files.map {|f| File.read(f) }.join
    end

    def html
      replacements = {
        "BODY"    => body,
        "TITLE"   => title
      }

      template = File.read(File.join(TEMPLATES, "main.html"))

      replacements.each do |key, value|
        template.gsub!("[#{key}]", value)
      end

      template
    end
  end
end
