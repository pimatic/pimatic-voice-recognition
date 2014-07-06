( ->
  recognition = null

  $(document).on "pagebeforecreate", '#index', (event) ->
    controlGroup = $('div#index [data-role=header] [data-role=controlgroup]') 
    talkButton = $('<a id="talk" class=" ui-btn ui-btn-inline ui-mini"></a>')
    controlGroup.prepend talkButton
    talkButton.text __('Speak')
    $('div#index h3').after controlGroup

    words = []
    status = 'idle'

    $(document).on "vclick", "#talk", (event, ui) ->
      unless recognition? then setup()
      if recognition?
        if status is 'idle'
          recognition.start()
          pimatic.showToast "What do you want to do?"
        else if status is 'listening'
          recognition.stop()
      talkButton.blur()

    setup = =>
      unless "webkitSpeechRecognition" of window
        pimatic.showToast "Sorry your browser is not supported."
      else
        recognition = new webkitSpeechRecognition()
        recognition.lang = "en-GB";
        recognition.onstart = ->
          status = 'listening'
          words = []
          talkButton.text __('Listening')

        recognition.onerror = (event) ->
          pimatic.showToast "Error: " + event.Error

        recognition.onend = ->
          status = 'idle'
          talkButton.text __('Speak')
          if words.length is 0
            pimatic.showToast "I couldn't hear you"
          else
            $.ajax(
              type: 'POST'
              url: "/api/speech"
              data: {words: words}
            ).done( (data) ->
              pimatic.showToast data
            )
        recognition.onresult = (event) ->
          for result in event.results[0]
            if result? then words.push result.transcript
          recognition.stop()
    
)() 

# voiceCallback = (matches) ->
