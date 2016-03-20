module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'

  class VoiceRecognitionPlugin extends env.plugins.Plugin
    actions: []

    init: (app, @framework, @config) =>

      @framework.on("after init", =>
        mobileFrontend = @framework.pluginManager.getPlugin 'mobile-frontend'
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
          res.status(400).send "Illegal Request"
          return
        words = (if Array.isArray words then words else [words])
        found = false
        for word in words
          context = @framework.ruleManager._createParseContext()
          parseResult = @framework.ruleManager._parseAction('speech-action', word, context)
          unless context.hasErrors()
            @framework.ruleManager._executeAction(parseResult.action, false).then( (message) =>
              res.status(200).send(message)
            ).catch( (e) =>
              res.status(200).send "Error: #{e.message}"
            ).done()
            found = true
            break
        unless found then res.status(200).send "Could not execute: #{words[0]}" 
      )
  return new VoiceRecognitionPlugin