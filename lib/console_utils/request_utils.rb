module ConsoleUtils #:nodoc:

  # = Request Utils
  # Provides the collection of tools to make JSON API requests and get formatted output.
  # To use system-installed +jq+ utility to format json, change +json_formatter+
  # option in the config.

  module RequestUtils
    extend ActiveSupport::Autoload

    autoload :RequestParams
    autoload :Requester
    autoload :Exap
    autoload :Remo

    autoload :JSONOutput do
      autoload :Default
      autoload :Jq
    end

    # :call-seq:
    #   autoken(id)
    #   autoken(:any)
    #
    # Returns user's token by primary key. Use <tt>:any</tt> to get random user.
    def autoken(id)
      ConsoleUtils.auto_token_for(id)
    end

    # :call-seq:
    #   exap(.get|.post|.put|...)(url, user_id = nil, **params)
    #
    # Local API requester context.
    # See also: <tt>ConsoleUtils::RequestUtils::Exap</tt>
    #
    # ==== Examples:
    #
    # Appends auth token of default user to params, makes request and prints formatted response:
    #
    #     exap.get("api/posts.json").preview
    #
    # Authorize user #42, also copy formatted response to the pasteboard:
    #
    #     exap.get("api/posts.json", 42).preview(&:pbcopy)
    #
    # Authorize random user:
    #
    #     exap.get("api/comments.json", :any).preview
    #
    # Use additional request params (skip the second parameter to use default user),
    # don't print response body:
    #
    #     exap.put("api/account.json", 42, user: { name: "Anton" })
    #
    # Skip auto-fetching user's token:
    #
    #     exap.post("api/signup.json", nil, user: { name: "Guest" }).preview

    def exap
      Exap.new(self)
    end

    # :call-seq:
    #   remo(.get|.post|.put|...)(url, user_id = nil, **params)
    #
    # Remote API requester context.
    # See also: <tt>ConsoleUtils::RequestUtils::Remo</tt>
    #
    # ==== Examples:
    # See +exap+ examples.
    def remo
      Remo.new(self)
    end
  end
end