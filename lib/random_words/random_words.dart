import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/random_words/Saved/saved_controller.dart';
import 'package:flutter_app/random_words/Suggestions/suggestions_controller.dart';
import 'package:flutter_app/random_words/style_constants.dart';
import 'package:flutter_app/random_words/word_pair_extension.dart';
import 'package:fluttertoast/fluttertoast.dart';

final SuggestionsController _suggestions = new SuggestionsController();
final SavedController _saved = new SavedController();

class RandomWords extends StatefulWidget {
  Future<Iterable<String>> _loadSaved() {
    return _saved.load();
  }

  @override
  RandomWordsState createState() {
    _loadSaved().then((list) => {
          _saved.addAll(list),
        });
    return new RandomWordsState();
  }
}

class SavedWords extends StatefulWidget {
  @override
  SavedWordsState createState() => new SavedWordsState();
}

class SavedWordsState extends State<SavedWords> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text("Saved"),
      ),
      body: _buildSaved(),
    );
  }

  Widget _buildSaved() {
    return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        separatorBuilder: (context, index) => Divider(
              color: Colors.grey[300],
            ),
        itemCount: _saved.length,
        itemBuilder: (BuildContext context, int index) =>
            _buildSavedRow(index));
  }

  Widget _buildSavedRow(int i) {
    final wordPair = _saved.saved.toList()[i];
    return new ListTile(
      title: new Text(
        format(wordPair),
        style: biggerFont,
      ),
      onLongPress: () {
        setState(() {
          _saved.remove(wordPair);
        });
        Fluttertoast.showToast(
          msg: "Deleted ${format(wordPair)}",
        );
      },
    );
  }
}

class RandomWordsState extends State<RandomWords> {
  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (BuildContext context, int index) => _buildRow(index));
  }

  Widget _buildRow(int i) {
    if (i.isOdd) {
      return Divider();
    }

    final index = i ~/ 2;
    if (index >= _suggestions.length) {
      _suggestions.generatePairs(10);
    }

    final wordPair = _suggestions.suggestions[index];
    final bool alreadySaved = _saved.contains(wordPair);
    return ListTile(
      title: Text(
        format(wordPair),
        style: biggerFont,
      ),
      trailing: new IconButton(
        icon: new Icon(alreadySaved ? Icons.favorite : Icons.favorite_border,
            color: alreadySaved ? Colors.red[800] : null),
        onPressed: () {
          setState(() {
            _onSaveClick(alreadySaved, wordPair);
          });
        },
      ),
      onTap: () {
        Fluttertoast.showToast(
          msg: "Pressed ${format(wordPair)}",
        );
      },
    );
  }

  void _onSaveClick(bool alreadySaved, WordPair wordPair) {
    alreadySaved ? _saved.remove(wordPair) : _saved.add(wordPair);
  }

  void _pushSaved() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SavedWords()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Startup Name Generator"),
        actions: <Widget>[
          new IconButton(
              tooltip: "Saved",
              icon: const Icon(Icons.list),
              onPressed: () {
                _pushSaved();
              }),
        ],
      ),
      body: _buildSuggestions(),
    );
  }
}
