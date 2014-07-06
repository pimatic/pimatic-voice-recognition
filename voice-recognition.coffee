module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  class VoiceRecognitionPlugin extends env.plugins.Plugin
    actions: []

    init: (@app, @framework, @config) =>
      _this = this

      @framework.on("after init", =>
        mobileFrontend = @framework.getPlugin 'mobile-frontend'
        if mobileFrontend?
          mobileFrontend.registerAssetFile 'js', 
            "pimatic-voice-recognition/app/voice-recognition-setup.coffee"
        else
          env.logger.warn "VoiceRecognitionPlugin could not find mobile-frontend. " +
            "No gui will be available"
      )

      app.post("/api/speech", (req, res, next) =>
        words = req.body.words
        unless words?
          res.send 400, "Illegal Request"
          return
        words = (if Array.isArray words then words else [words])
        found = false
        for word in words
          console.log "word:", word
          context = @framework.ruleManager.createParseContext()
          parseResult = @framework.ruleManager.parseAction('speech-action', word, context)
          unless context.hasErrors()
            @framework.ruleManager.executeAction(parseResult.action, false).then( (message) =>
              res.send 200, message
            ).catch( (e) =>
              res.send 200, "Error: #{e.message}"
            ).done()
            found = true
            break
        unless found then res.send 200, "Could not execute: #{words[0]}" 
      )
  return new VoiceRecognitionPlugin