# Remove const to avoid
# warning: already initialized constant FORMAT_NAMES
#
# only remove if it's defined.
# constant Gollum::Page::FORMAT_NAMES not defined (NameError)
Gollum::Page.send :remove_const, :FORMAT_NAMES if defined? Gollum::Page::FORMAT_NAMES
# Limit Formats
Gollum::Page::FORMAT_NAMES = { :markdown  => "Markdown", :asciidoc => "AsciiDoc" }

=begin
Valid formats are:
{ :markdown  => "Markdown",
  :textile   => "Textile",
  :rdoc      => "RDoc",
  :org       => "Org-mode",
  :creole    => "Creole",
  :rest      => "reStructuredText",
  :asciidoc  => "AsciiDoc",
  :mediawiki => "MediaWiki",
  :pod       => "Pod" }
=end

# Specify the path to the Wiki.
gollum_path = '/root/docs'
Precious::App.set(:default_markup, :asciidoc)

# Specify the wiki options.
wiki_options = {
  :css              => true,
  :js               => false,
  #:template_dir     => path,
  #:page_file_dir    => path,
  :ref              => 'master',
  :repo_is_bare     => false,
  :allow_editing    => true,
  :live_preview     => true,
  :allow_uploads    => true,
  :per_page_uploads => false,
  :mathjax          => true,
  #:mathjax_config   => source,
  :user_icons       => 'gravatar',
  :collapse_tree    => false,
  :h1_title         => true,
  :show_all         => false,
  :universal_toc    => false,
  :filter_chain     => [:Metadata, :PlainText, :TOC, :RemoteCode, :GRAPHVIZ, :Code, :Macro, :Sanitize, :WSD, :Tags, :Render]
}
Precious::App.set(:wiki_options, wiki_options)
Precious::App.set(:gollum_path, gollum_path)

# Set as Sinatra environment as production (no stack traces)
Precious::App.set(:environment, :production)

# Setup Omniauth via Omnigollum.
require 'omnigollum'
require 'omniauth-ldap'

options = {
  # OmniAuth::Builder block is passed as a proc
  :providers => Proc.new do
    provider :ldap,
      :title => "SSZ LDAP",
      :host => 'sszldap01.ssz.tekelec.com',
      :port => 389,
      :method => :plain,
      :base => 'ou=ssz,dc=tekelec,dc=com',
      :uid => 'uid'
  end,
  :dummy_auth => false,
  # Specify committer name as just the user name
  :author_format => Proc.new { |user| user.name },
  # Specify committer e-mail as just the user e-mail
  :author_email => Proc.new { |user| user.email },
  # Only allow DVAT to alter files
  :authorized_users => ["dmayo", "gkannaiy", "igowtham", "jfedor", "jposton", "mchill", "rbodford", "rhew"]
}

# :omnigollum options *must* be set before the Omnigollum extension is registered
Precious::App.set(:omnigollum, options)
Precious::App.register Omnigollum::Sinatra


