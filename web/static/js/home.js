let Home = {
  socket: null,
  shortUrlForm: "#home-page-short-url-form",
  longUrlInput: "#long-url",
  init: function (socket) {
    self = this
    self.socket = socket
    $(self.shortUrlForm).submit(function(event) {
      if(self.getFormAction() == 'copy') {
      } else {
        self.run()
      }
      event.preventDefault();
    })
    $(`${self.shortUrlForm} a.exit-copy`).click(function() {
      self.toggleButtonAction('')
      $(`${self.shortUrlForm} a.exit-copy`).addClass('hidden')
        $(self.longUrlInput).val('')
      event.preventDefault();
    })
    self.channel = self.socket.channel("home:page", {})
  },
  connectToChannel: function () {
    self = this
    if(self.channel.state == 'closed') {
      self.channel.join()
        .receive("ok", resp => { console.log("Joined successfully", resp) })
        .receive("error", resp => { console.log("Unable to join", resp) })

      self.channel.on("create_elink", (resp) => {
        self.toggleButtonAction(resp.slug)
        $(self.longUrlInput).val(resp.slug)
        $(self.longUrlInput).select()
      })
    }
  },
  toggleButtonAction: function (link) {
    self = this
    let button = `${self.shortUrlForm} input[type=submit]`
    let buttonText = ''
    $(button).toggleClass('short-url-copy')
    if(self.getFormAction() == 'copy') {
        self.setFormAction('shorten')
        $(button).val("Shorten")
        $(button).attr('data-clipboard-text', '')
    } else {
        self.setFormAction('copy')
        $(button).val("Copy")
        $(button).attr('data-clipboard-text', link)
        $(`${self.shortUrlForm} a.exit-copy`).removeClass('hidden')
    }
  },
  getFormAction: function () {
    return $(`${self.shortUrlForm} input[name=form-action]`).val()
  },
  setFormAction: function (action) {
    return $(`${self.shortUrlForm} input[name=form-action]`).val(action)
  },
  run: function() {
    self = this
    self.connectToChannel()

    let payload = {url: $(self.longUrlInput).val()}
    self.channel.push("create_elink", payload)
        .receive("error", e => self.handleError(e))
  },
  handleError: function(msg) {
    console.log(`=======errrrorrrr:`)
    console.log(msg)
  },
}

export default Home
