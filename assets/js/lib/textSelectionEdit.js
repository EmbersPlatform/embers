/**
 * Text selection edit
 * @author dorgandash@gmail.com
 * Only works for IE11+ welcome to XXI century
 */

export default function textSelectionEdit(textarea, startingTag = '', endingTag = '') {
  var bDouble = arguments.length > 2;

  var selStart = textarea.selectionStart;
  var selEnd = textarea.selectionEnd;

  var front = textarea.value.substring(0, selStart);
  var back = textarea.value.substring(selEnd, textarea.value.length);
  var selection = textarea.value.substring(selStart, selEnd);

  var txt = startingTag + (bDouble ? selection + endingTag : endingTag);

  textarea.value = front + txt + back;

  textarea.setSelectionRange(bDouble || selStart === selEnd ? selStart + startingTag.length : selStart, (bDouble ? selEnd : selStart) + startingTag.length);

  textarea.focus();
}