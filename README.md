# flutter_object_form_field

Working with `TextFormField` is nice until you want to work with something other than `String`. For example, if you want
invoke date timer picker, you have to create a focus node, listen for focus, show the dialog when needed. If you do not
want to use some special object to store the selected value, you will end up with parsing the data before save just because
`TextFormField` only works with `String`.

This library provides `ObjectFormField<T>` that works much better for these cases. You provide it with a function that
turns your object into `String` and a `picker` async function that returns newly picked object (`DateTime` from date picker).

Usage
--

To use this plugin, add flutter_object_form_field as a dependency in your pubspec.yaml file.

Examples
--

```dart

//
// USAGE WITH CUSTOM OBJECT
//
ObjectFormField<Emotion>(
  objectToString: (emotion) => emotion?.name,
  pickValue: (oldEmotion) async {
    // returns an emotion object
    return await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EmotionsPage()));
  },
  decoration: InputDecoration(labelText: 'Emotion'),
  validator: (value) {
    if (value == null) {
      return 'You have to pick an emotion';

    if (value.name == 'Sadness') {
      return 'Show me your smile!';
    }
  },
),
//
// USAGE WITH DATE TIME
//
ObjectFormField<DateTime>(
  // can use some kind of formatter
  objectToString: (dateTime) => dateTime?.toString(),
  pickValue: (oldDate) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  },
  decoration: InputDecoration(labelText: 'Date'),
  validator: (value) {
    if (value == null) {
      return 'You have to select date';
    }
  },
),
```

Contribution and Support
--
Contributions are welcome!<br>
If you want to contribute code please create a PR<br>
If you find a bug or want a feature, please fill an issue