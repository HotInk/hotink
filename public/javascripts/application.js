// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function clearText(theField)
{
if (theField.defaultValue == theField.value)
theField.value = '';
}

function addText(theField)
{
if (theField.value == '')
theField.value = theField .defaultValue;
}