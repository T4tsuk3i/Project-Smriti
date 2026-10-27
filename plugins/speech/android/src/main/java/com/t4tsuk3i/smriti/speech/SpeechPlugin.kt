package com.t4tsuk3i.smriti.speech

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import app.tauri.annotation.Command
import app.tauri.annotation.Permission
import app.tauri.annotation.PermissionCallback
import app.tauri.annotation.TauriPlugin
import app.tauri.plugin.Invoke
import app.tauri.plugin.JSObject
import app.tauri.plugin.Plugin
import java.util.Locale

@TauriPlugin(
  permissions = [
    Permission(
      alias = "microphone",
      strings = [Manifest.permission.RECORD_AUDIO]
    )
  ]
)
class SpeechPlugin(private val activity: Activity) : Plugin(activity), RecognitionListener {
  private var recognizer: SpeechRecognizer? = null
  private var pendingStart: Invoke? = null

  @Command
  fun start(invoke: Invoke) {
    pendingStart = invoke
    if (activity.checkSelfPermission(Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
      requestPermissionForAlias("microphone", invoke, "microphoneResult")
      return
    }
    startListening(invoke)
  }

  @PermissionCallback
  fun microphoneResult(invoke: Invoke) {
    if (activity.checkSelfPermission(Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED) {
      startListening(invoke)
    } else {
      pendingStart = null
      invoke.reject("Microphone permission is required.")
    }
  }

  private fun startListening(invoke: Invoke) {
    if (!SpeechRecognizer.isRecognitionAvailable(activity)) {
      pendingStart = null
      invoke.reject("Speech recognition is not available on this device.")
      return
    }

    recognizer?.destroy()
    recognizer = SpeechRecognizer.createSpeechRecognizer(activity).also {
      it.setRecognitionListener(this)
    }

    val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
      putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
      putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault().toLanguageTag())
      putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
      putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
      putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE, true)
      putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 800L)
      putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 600L)
      putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 800L)
    }

    recognizer?.startListening(intent)
    invoke.resolve()
  }

  @Command
  fun stop(invoke: Invoke) {
    recognizer?.stopListening()
    invoke.resolve()
  }

  @Command
  fun cancel(invoke: Invoke) {
    stopAndDestroy()
    invoke.resolve()
  }

  private fun stopAndDestroy() {
    pendingStart = null
    recognizer?.cancel()
    recognizer?.destroy()
    recognizer = null
  }

  private fun bestText(bundle: Bundle): String {
    val results = bundle.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
    return results?.firstOrNull()?.trim().orEmpty()
  }

  private fun emit(event: String, payload: JSObject) {
    trigger(event, payload)
  }

  override fun onReadyForSpeech(params: Bundle?) {
    emit("ready", JSObject())
  }

  override fun onBeginningOfSpeech() {
    emit("speechstart", JSObject())
  }

  override fun onRmsChanged(rmsdB: Float) {
    if (rmsdB > -2f) {
      val payload = JSObject()
      payload.put("value", rmsdB.toDouble())
      emit("level", payload)
    }
  }

  override fun onBufferReceived(buffer: ByteArray?) {}

  override fun onEndOfSpeech() {
    emit("speechend", JSObject())
  }

  override fun onError(error: Int) {
    val payload = JSObject()
    payload.put("code", error)
    payload.put("message", errorMessage(error))
    emit("error", payload)
    stopAndDestroy()
  }

  override fun onResults(results: Bundle?) {
    val text = results?.let { bestText(it) }.orEmpty()
    val payload = JSObject()
    payload.put("text", text)
    emit("result", payload)
    stopAndDestroy()
  }

  override fun onPartialResults(partialResults: Bundle?) {
    val text = partialResults?.let { bestText(it) }.orEmpty()
    if (text.isNotEmpty()) {
      val payload = JSObject()
      payload.put("text", text)
      emit("partial", payload)
    }
  }

  override fun onEvent(eventType: Int, params: Bundle?) {}

  private fun errorMessage(error: Int): String {
    return when (error) {
      SpeechRecognizer.ERROR_AUDIO -> "Audio recording error."
      SpeechRecognizer.ERROR_CLIENT -> "Speech client error."
      SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "Microphone permission is required."
      SpeechRecognizer.ERROR_NETWORK -> "Network error from speech recognition."
      SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "Speech recognition timed out."
      SpeechRecognizer.ERROR_NO_MATCH -> "I didn't catch that. Try again."
      SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "Speech recognition is busy. Try again."
      SpeechRecognizer.ERROR_SERVER -> "Speech recognition server error."
      SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "I didn't hear anything. Try again."
      else -> "Speech recognition failed."
    }
  }
}
