module.exports = (env) ->

  convict = env.require "convict"
  Q = env.require 'q'
  assert = env.require 'cassert'

  class SpeakApi extends env.plugins.Plugin
    init: (app, server, @config) =>
      env.logger.warn """
      This plugin is deprecated and will be replaced with pimatic-voice-recognition.
      """

  return new SpeakApi