library checklist.widgets;

import 'colors.dart';

// Material UI
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Audio Player
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

// Globals
final AudioCache PLAYER = AudioCache(prefix:'sounds/');

////////////////////////////
/// Image Sound Checkbox ///
////////////////////////////
class ImageSoundCheckbox extends StatefulWidget {
  // Stateful Widget for Customized Checkbox with Images and Sound Effect
  // Constructor
  const ImageSoundCheckbox({
    Key key,
    @required this.value,
    @required this.onChanged,
  }) : super(key: key);

  // Parameters
  final bool value;
  final ValueChanged<bool> onChanged;

  // State Override
  @override
  ImageSoundCheckboxState createState() => ImageSoundCheckboxState();
}

class ImageSoundCheckboxState extends State<ImageSoundCheckbox> {
  // Checkbox
  final Widget checkedImage    = Image.asset('assets/images/checked.png');
  final Widget notCheckedImage = Image.asset('assets/images/not_checked.png');
  bool _value;
  
  void _handleValueChange() {
    _value = !_value;
  }

  Future<AudioPlayer> _playSoundEffect() async {
    return await PLAYER.play("pop.wav", mode: PlayerMode.LOW_LATENCY, volume: 1.0);
  }

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(5.0),
        child: IconButton(
          icon: _value ? checkedImage : notCheckedImage,
          iconSize: 15,
          onPressed: () {
            _playSoundEffect();
            _handleValueChange();
            widget.onChanged(_value);
          }
        )
      )
    );
  }
}

////////////////////////////
/// Pinnable Icon Button ///
////////////////////////////
class PinnableIconButton extends StatefulWidget {
  const PinnableIconButton({
    Key key,
    @required this.value,
    @required this.color,
    @required this.onChanged
  }) : super(key: key);

  final bool value;
  final MaterialColor color;
  final ValueChanged<bool> onChanged;

  @override
  PinnableIconButtonState createState() => PinnableIconButtonState();
}

class PinnableIconButtonState extends State<PinnableIconButton> {
  bool _value;

  void _handleValueChange() {
    _value = !_value;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _value = widget.value;   
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawMaterialButton(
      onPressed: () {
        _handleValueChange();
        widget.onChanged(_value);
      },
      elevation: 0.0,
      fillColor: widget.color,
      child: Icon(
        Icons.push_pin_sharp,
        size: 18.0,
        color: _value ? (
          ThemeData.estimateBrightnessForColor(widget.color) == Brightness.light 
            ? colorMap[0xFF1D2021]
            : Colors.white
          ) 
        : widget.color
      ),
      padding: EdgeInsets.all(5.0),
      shape: CircleBorder()
    );
  }
}
