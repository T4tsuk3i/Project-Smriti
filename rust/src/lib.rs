//! Smriti core.
//!
//! The Rust side owns the memory primitives that should not depend on the UI:
//! decay, overlap scoring, and future on-device retrieval. The Flutter app can
//! call these over FFI once the Android/iOS bridge is wired.

use std::collections::HashSet;
use std::ffi::{c_char, CStr, CString};

pub const VERSION: &str = env!("CARGO_PKG_VERSION");

pub fn version() -> &'static str {
	VERSION
}

/// Ebbinghaus-style decay. Returns importance after `days` since last access.
pub fn decay(importance: f64, days: f64, half_life_days: f64) -> f64 {
	if importance <= 0.0 || days <= 0.0 || half_life_days <= 0.0 {
		return importance.clamp(0.0, 1.0);
	}

	let rate = std::f64::consts::LN_2 / half_life_days;
	(importance * (-rate * days).exp()).clamp(0.0, 1.0)
}

fn words(text: &str) -> HashSet<String> {
	text.split(|c: char| !c.is_alphanumeric())
		.map(|word| word.to_lowercase())
		.filter(|word| word.len() > 2)
		.collect()
}

/// Jaccard similarity between two strings, using alphanumeric word sets.
pub fn jaccard(a: &str, b: &str) -> f64 {
	let left = words(a);
	let right = words(b);
	if left.is_empty() && right.is_empty() {
		return 1.0;
	}
	if left.is_empty() || right.is_empty() {
		return 0.0;
	}

	let intersection = left.intersection(&right).count() as f64;
	let union = left.union(&right).count() as f64;
	intersection / union
}

/// Simple keyword overlap score used by future local retrieval.
pub fn keyword_overlap(query: &str, document: &str) -> f64 {
	let query_words = words(query);
	if query_words.is_empty() {
		return 0.0;
	}
	let document_words = words(document);
	let hits = query_words.intersection(&document_words).count() as f64;
	hits / query_words.len() as f64
}

#[unsafe(no_mangle)]
pub extern "C" fn smriti_version() -> *mut c_char {
	CString::new(VERSION).unwrap_or_default().into_raw()
}

/// # Safety
/// `ptr` must be a pointer returned by `smriti_version` (or another Smriti
/// string function) that has not already been freed.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn smriti_string_free(ptr: *mut c_char) {
	if ptr.is_null() {
		return;
	}
	// SAFETY: the caller promises this came from CString::into_raw above.
	drop(unsafe { CString::from_raw(ptr) });
}

/// # Safety
/// `ptr` must be a valid, null-terminated UTF-8 string.
#[unsafe(no_mangle)]
pub unsafe extern "C" fn smriti_echo(ptr: *const c_char) -> *mut c_char {
	if ptr.is_null() {
		return std::ptr::null_mut();
	}
	// SAFETY: the caller promises a valid C string.
	let text = unsafe { CStr::from_ptr(ptr) }.to_string_lossy();
	CString::new(text.as_ref()).unwrap_or_default().into_raw()
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn decay_reaches_half_at_half_life() {
		let value = decay(1.0, 30.0, 30.0);
		assert!((value - 0.5).abs() < 1e-9);
	}

	#[test]
	fn decay_keeps_protected_values() {
		assert_eq!(decay(0.8, 0.0, 30.0), 0.8);
	}

	#[test]
	fn jaccard_matches_overlap() {
		let value = jaccard("the quick brown fox", "the quick blue fox");
		assert!((value - 0.6).abs() < 1e-9);
	}

	#[test]
	fn keyword_overlap_counts_query_terms() {
		let value = keyword_overlap("invoices avoided", "I avoided invoices again");
		assert!((value - 1.0).abs() < 1e-9);
	}

	#[test]
	fn version_is_not_empty() {
		assert!(!version().is_empty());
	}
}
