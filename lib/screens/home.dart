import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:music_player/components/music_player_theme.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:marquee/marquee.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

//SingleTickerProvider means that the _homeState class has only one controller
class _HomeState extends State<Home> {
  //This is a class found in plugin: on_audio_query
  final OnAudioQuery _audioQuery = OnAudioQuery();

//This is a class found in plugin: just_audio
  final AudioPlayer _player = AudioPlayer();
  List<SongModel> songs = [];
  List<SongModel> search = [];
  List<SongModel> filteredSongs = [];
  String currentSongTitle = '';
  String? currentArtist = '';

  int currentIndex = 0;
  int currentSongID = 0;

  bool isPlayerViewVisible = false;
  bool isShuffle = false;

  bool isPlaying = false;

  bool isTapped = true;

  bool isHome = true;
  bool isQueue = false;
  bool isSearch = false;

  String searchData = '';

  //Controller for TextField to control the properties of textfield
  final TextEditingController _textEditingController = TextEditingController();

  //Focus node used in TextField to automatically focused when search icon was clicked
  final FocusNode _focusNode = FocusNode();

//List of Songs that are filtered by the search bar

//A string of text that used in finding the relevance to the data contained in the filteredSongs
  String _searchText = '';

  void _changePlayerVisibility() {
    setState(() {
      isPlayerViewVisible = true;
    });
  }

  //Value sort
  int _selectedValueSort = 0;
  final List<SongSortType> sortTechnique = [
    SongSortType.TITLE,
    SongSortType.ARTIST,
    SongSortType.DATE_ADDED,
    SongSortType.ALBUM,
  ];

  //Change order ASC or DESC
  int _selectedValueOrder = 0;
  final List<OrderType> orderTechnique = [
    OrderType.ASC_OR_SMALLER,
    OrderType.DESC_OR_GREATER,
  ];

  requestStoragePermission() async {
    //If the platform is not web, then get permission

    if (!kIsWeb) {
      bool permissionsStatus = await _audioQuery.permissionsStatus();

      //If persmissionsStatus is denied, then it will request. eg. The dialogbox popped up when it is needed to use permission
      if (!permissionsStatus) {
        await _audioQuery.permissionsRequest();
      }

      setState(() {});
    }
  }

  //Initializing the default list of song
  defaultSongs(defaultsong) {
    setState(() {
      search = defaultsong.data!;
    });
  }

  //This member function shows the content of bottom sheet wherein it has radio button ASC or DESC
  changeOrder() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.23,
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30.0)),
                  color: MusicPlayerTheme().primaryBottomSheetColor),
              child: Stack(children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                    child: Icon(
                      Icons.maximize_rounded,
                      size: 50.0,
                      color: MusicPlayerTheme().primaryColor,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RadioListTile(
                      activeColor: MusicPlayerTheme().selectedTile,
                      value: 0,
                      groupValue: _selectedValueOrder,
                      onChanged: (value) {
                        setState(() {
                          _selectedValueOrder = value!;
                          Navigator.pop(context);
                        });
                      },
                      title: Text(
                        'Ascending',
                        style:
                            TextStyle(color: MusicPlayerTheme().primaryColor),
                      ),
                    ),
                    RadioListTile(
                      activeColor: MusicPlayerTheme().selectedTile,
                      value: 1,
                      groupValue: _selectedValueOrder,
                      onChanged: (value) {
                        setState(() {
                          _selectedValueOrder = value!;
                          Navigator.pop(context);
                        });
                      },
                      title: Text(
                        'Descending',
                        style:
                            TextStyle(color: MusicPlayerTheme().primaryColor),
                      ),
                    ),
                  ],
                )
              ]));
        });
  }

  //Sorts song depends on the user choice
  sortSongs() {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30.0)),
                  color: MusicPlayerTheme().primaryBottomSheetColor),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                      child: Icon(
                        Icons.maximize_rounded,
                        size: 50.0,
                        color: MusicPlayerTheme().primaryColor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RadioListTile(
                        activeColor: MusicPlayerTheme().selectedTile,
                        value: 0,
                        groupValue: _selectedValueSort,
                        onChanged: (value) {
                          setState(() {
                            _selectedValueSort = value!;
                            Navigator.pop(context);
                          });
                        },
                        title: Text(
                          'Sort Alphabetically',
                          style:
                              TextStyle(color: MusicPlayerTheme().primaryColor),
                        ),
                      ),
                      RadioListTile(
                        activeColor: MusicPlayerTheme().selectedTile,
                        value: 1,
                        groupValue: _selectedValueSort,
                        onChanged: (value) {
                          setState(() {
                            _selectedValueSort = value!;
                            Navigator.pop(context);
                          });
                        },
                        title: Text(
                          'Sort by Artist',
                          style:
                              TextStyle(color: MusicPlayerTheme().primaryColor),
                        ),
                      ),
                      RadioListTile(
                        activeColor: MusicPlayerTheme().selectedTile,
                        value: 2,
                        groupValue: _selectedValueSort,
                        onChanged: (value) {
                          setState(() {
                            _selectedValueSort = value!;
                            Navigator.pop(context);
                          });
                        },
                        title: Text(
                          'Sort by Date',
                          style:
                              TextStyle(color: MusicPlayerTheme().primaryColor),
                        ),
                      ),
                      RadioListTile(
                        activeColor: MusicPlayerTheme().selectedTile,
                        value: 3,
                        groupValue: _selectedValueSort,
                        onChanged: (value) {
                          setState(() {
                            _selectedValueSort = value!;
                            Navigator.pop(context);
                          });
                        },
                        title: Text(
                          'Sort by Album',
                          style:
                              TextStyle(color: MusicPlayerTheme().primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ));
        });
  }

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          _player.positionStream,
          _player.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));

  @override
  void initState() {
    super.initState();

    //Initialize the request permission
    requestStoragePermission();

    _player.currentIndexStream.listen((index) async {
      if (index != null) {
        _updateCurrentPlayingSongDetails(index);
      }
    });

    _player.playerStateStream.listen((playerState) async {
      if (playerState.playing == true) {
        setState(() {
          isPlaying = true;
        });
      }
      if (playerState.processingState == ProcessingState.completed) {
        setState(() {
          isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    _player.dispose();
    //Dispose the controller
  }

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (isHome) {
      child = Container(
        decoration: BoxDecoration(
          gradient: MusicPlayerTheme().linearGradientBody,
        ),
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder<List<SongModel>>(
            future: _audioQuery.querySongs(
              sortType: sortTechnique[_selectedValueSort],
              orderType: orderTechnique[_selectedValueOrder],
              uriType: UriType.EXTERNAL,
              ignoreCase: true,
            ),

            //Builder for future widget
            builder: (context, item) {
              //if the directory still retrieving mp3 files
              if (item.data == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              //if the directory has no mp3 ext files
              if (item.data!.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              //Builds the list of song retrieved
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: const Text('Music Player'),
                    elevation: 0,
                    //Create Screen to make a Search Page
                    actions: [
                      IconButton(
                          onPressed: () {
                            defaultSongs(item);
                            setState(() {
                              isHome = false;
                              isQueue = false;
                              isSearch = true;
                            });
                          },
                          icon: const Icon(Icons.search)),
                    ],

                    //The number of Tabbar depends on the length initialized on the controller

                    floating: true,
                    // other properties of SliverAppBar can be set here
                  ),
                  SliverAppBar(
                    pinned: true,
                    elevation: 0,

                    //Create Screen to make a Search Page
                    actions: [
                      IconButton(
                          onPressed: () => changeOrder(),
                          icon: const Icon(Icons.swap_vert_rounded,
                              color: Colors.white)),
                      IconButton(
                          onPressed: () => sortSongs(),
                          icon: const Icon(
                            Icons.sort_rounded,
                            color: Colors.white,
                          )),
                    ],
                    // other properties of SliverAppBar can be set here
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      //Return the tile of every song
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: ListTile(
                          trailing: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (currentSongID == item.data![index].id &&
                                  isPlaying)
                                MiniMusicVisualizer(
                                  color: MusicPlayerTheme().musicVisualiser,
                                  width: 4,
                                  height: 15,
                                ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),

                          title: SizedBox(
                            height: 18,
                            child: Text(
                              (item.data![index].title).replaceAll('_', ' '),
                              style: TextStyle(
                                  color: currentSongID != item.data![index].id
                                      ? MusicPlayerTheme().primaryColor
                                      : MusicPlayerTheme().selectedTile),
                              maxLines: 1,
                            ),
                          ),

                          subtitle: Text(
                            item.data![index].artist ?? "No Artist",
                            style: TextStyle(
                                color: MusicPlayerTheme().secondaryColor),
                            maxLines: 1,
                          ),

                          //Retrieve the song illustration
                          leading: QueryArtworkWidget(
                            id: item.data![index].id,
                            type: ArtworkType.AUDIO,
                            artworkBorder: BorderRadius.zero,
                            keepOldArtwork: true,

                            //If the artwork or the song has no illustration
                            nullArtworkWidget: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: MusicPlayerTheme()
                                      .primaryDefaultArtworkBackgroundColor,
                                ),
                                child: const Icon(
                                  Icons.music_note_sharp,
                                  color: Colors.white,
                                )),
                          ),

                          onTap: () async {
                            if (currentSongID != item.data![index].id) {
                              //Store the full list of songs
                              songs = item.data!;
                              _changePlayerVisibility();
                              // Play a sound as a one-shot, releasing its resources when it finishes playing.

                              _updateCurrentPlayingSongDetails(index);

                              _player.setAudioSource(createPlaylist(item.data),
                                  initialIndex: index);
                              _player.play();
                            } else {
                              setState(() {
                                isTapped = !isTapped;
                              });
                            }
                          },
                        ),
                      );
                    }, childCount: item.data!.length),
                  ),
                ],
              );
            }),
      );
    }
    //Is Queue Music
    else if (isSearch) {
      child = WillPopScope(
        onWillPop: () async {
          setState(() {
            isSearch = false;
            isQueue = false;
            isHome = true;
            searchData = '';
            filteredSongs = [];

            SystemChannels.textInput.invokeMethod('TextInput.hide');
            _textEditingController.clear();
          });

          return false;
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: MusicPlayerTheme().linearGradientBody,
          ),
          height: MediaQuery.of(context).size.height,
          child: CustomScrollView(slivers: [
            SliverAppBar(
              pinned: true,
              title: TextField(
                controller: _textEditingController,
                focusNode: _focusNode,

                style: const TextStyle(color: Colors.white),

                //When the text field value was changed the block of code execute
                onChanged: (value) {
                  setState(() {
                    //It will be used to find the user's searching
                    _searchText = value;

                    //A filtered list that will be display
                    filteredSongs = search
                        .where((item) =>
                            item.title.toLowerCase().contains(_searchText))
                        .toList();

                    if (filteredSongs.isEmpty) {
                      searchData = 'Nothing found';
                    } else {
                      searchData = '';
                    }
                  });
                },

                //Act as a placeholder
                decoration: const InputDecoration(
                  labelText: 'Search Songs',
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              leading: IconButton(
                  onPressed: () {
                    setState(() {
                      isSearch = false;
                      isHome = true;
                    });
                  },
                  icon: const Icon(Icons.arrow_back)),
              actions: [
                _textEditingController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _textEditingController.clear();
                          setState(() {
                            filteredSongs = [];
                          });
                        },
                        icon: const Icon(Icons.close))
                    : IconButton(
                        onPressed: () {
                          _focusNode.requestFocus();
                        },
                        icon: const Icon(Icons.search)),
              ],
            ),

            //If the textfield is empty then the icon button will change to search, vice versa to close

            //If the filtered songs is empty, then it will display no songs found
            filteredSongs.isNotEmpty
                ? SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      //Return the tile of every song
                      return SizedBox(
                        child: ListTile(
                          trailing: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (currentSongID == filteredSongs[index].id &&
                                  isPlaying)
                                MiniMusicVisualizer(
                                  color: MusicPlayerTheme().musicVisualiser,
                                  width: 4,
                                  height: 15,
                                ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.more_vert,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),

                          title: SizedBox(
                            height: 18,
                            child: Text(
                              (filteredSongs[index].title).replaceAll('_', ' '),
                              style: TextStyle(
                                  color:
                                      currentSongID != filteredSongs[index].id
                                          ? MusicPlayerTheme().primaryColor
                                          : MusicPlayerTheme().selectedTile),
                              maxLines: 1,
                            ),
                          ),

                          subtitle: Text(
                            filteredSongs[index].artist ?? "No Artist",
                            style: TextStyle(
                                color: MusicPlayerTheme().secondaryColor),
                            maxLines: 1,
                          ),

                          //Retrieve the song illustration
                          leading: QueryArtworkWidget(
                            id: filteredSongs[index].id,
                            type: ArtworkType.AUDIO,
                            artworkBorder: BorderRadius.zero,
                            keepOldArtwork: true,

                            //If the artwork or the song has no illustration
                            nullArtworkWidget: Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: MusicPlayerTheme()
                                      .primaryDefaultArtworkBackgroundColor,
                                ),
                                child: const Icon(
                                  Icons.music_note_sharp,
                                  color: Colors.white,
                                )),
                          ),

                          onTap: () async {
                            // Play a sound as a one-shot, releasing its resources when it finishes playing.
                            songs = filteredSongs;
                            if (songs[index].id != currentSongID) {
                              _changePlayerVisibility();
                              // Play a sound as a one-shot, releasing its resources when it finishes playing.

                              _updateCurrentPlayingSongDetails(index);

                              _player.setAudioSource(createPlaylist(songs),
                                  initialIndex: index);
                              _player.play();
                            } else {
                              setState(() {
                                isTapped = !isTapped;
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                                filteredSongs = search;
                              });
                            }
                          },
                        ),
                      );
                    }, childCount: filteredSongs.length),
                  )
                : SliverToBoxAdapter(
                    child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                            child: Text(
                          searchData,
                          style: TextStyle(
                              color: MusicPlayerTheme().primaryColor,
                              fontSize: 16),
                        ))))
          ]),
        ),
      );
    } else if (isQueue) {
      child = WillPopScope(
        onWillPop: () async {
          setState(() {
            isSearch = false;
            isHome = true;
            isQueue = false;
            searchData = '';
            filteredSongs = [];
            SystemChannels.textInput.invokeMethod('TextInput.hide');
            _textEditingController.clear();
          });

          return false;
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: MusicPlayerTheme().linearGradientBody,
          ),
          height: MediaQuery.of(context).size.height,
          child: CustomScrollView(slivers: [
            SliverAppBar(
              pinned: true,
              title: const Text('Song Queue'),
              leading: IconButton(
                  onPressed: () {
                    setState(() {
                      isQueue = false;
                      isHome = true;
                      isSearch = false;
                    });
                  },
                  icon: const Icon(Icons.arrow_back)),
              actions: [
                IconButton(
                    onPressed: () async {
                      setState(() {
                        isShuffle = !isShuffle;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isShuffle ? 'Shuffle On' : 'Shuffle Off',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14.0),
                            ),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.only(
                                bottom: 80, left: 30, right: 30),
                            duration: const Duration(milliseconds: 600),
                            backgroundColor:
                                const Color.fromARGB(131, 64, 66, 88),
                            elevation: 0,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                          ),
                        );
                      });
                      await _player.setShuffleModeEnabled(isShuffle);
                    },
                    icon: Icon(
                      Icons.shuffle_rounded,
                      color: isShuffle ? Colors.white : Colors.grey,
                    )),
              ],
            ),

            //If the textfield is empty then the icon button will change to search, vice versa to close

            //If the filtered songs is empty, then it will display no songs found
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                //Return the tile of every song
                return SizedBox(
                  child: ListTile(
                    trailing: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentSongID == songs[index].id && isPlaying)
                          MiniMusicVisualizer(
                            color: MusicPlayerTheme().musicVisualiser,
                            width: 4,
                            height: 15,
                          ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),

                    title: SizedBox(
                      height: 18,
                      child: Text(
                        (songs[index].title).replaceAll('_', ' '),
                        style: TextStyle(
                            color: currentSongID != songs[index].id
                                ? MusicPlayerTheme().primaryColor
                                : MusicPlayerTheme().selectedTile),
                        maxLines: 1,
                      ),
                    ),

                    subtitle: Text(
                      songs[index].artist ?? "No Artist",
                      style:
                          TextStyle(color: MusicPlayerTheme().secondaryColor),
                      maxLines: 1,
                    ),

                    //Retrieve the song illustration
                    leading: QueryArtworkWidget(
                      id: songs[index].id,
                      type: ArtworkType.AUDIO,
                      artworkBorder: BorderRadius.zero,
                      keepOldArtwork: true,

                      //If the artwork or the song has no illustration
                      nullArtworkWidget: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: MusicPlayerTheme()
                                .primaryDefaultArtworkBackgroundColor,
                          ),
                          child: const Icon(
                            Icons.music_note_sharp,
                            color: Colors.white,
                          )),
                    ),

                    onTap: () async {
                      if (songs[index].id != currentSongID) {
                        _changePlayerVisibility();
                        // Play a sound as a one-shot, releasing its resources when it finishes playing.

                        _updateCurrentPlayingSongDetails(index);

                        _player.setAudioSource(createPlaylist(songs),
                            initialIndex: index);
                        _player.play();
                      } else {
                        setState(() {
                          isTapped = !isTapped;
                        });
                      }
                    },
                  ),
                );
              }, childCount: songs.length),
            )
          ]),
        ),
      );
    } else {
      child = Container();
    }

    return Scaffold(
      //Shows the drawer, the hamburger icon located at the upper left corner
      backgroundColor: MusicPlayerTheme().primaryAppBarColor,
      //Shows the body of each Tab, so each tab has unique data
      body: SafeArea(
        child: child,
      ),
      bottomSheet: isPlayerViewVisible
          ? Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: isTapped
                  ? MediaQuery.of(context).size.height * 0.1
                  : MediaQuery.of(context).size.height * 0.96,
              child: isTapped
                  ? Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isTapped = !isTapped;
                              SystemChannels.textInput
                                  .invokeMethod('TextInput.hide');
                            });
                          },
                          child: Container(
                            color: MusicPlayerTheme().primaryBottomSheetColor,
                            child: ListTile(
                              leading: QueryArtworkWidget(
                                id: currentSongID,
                                keepOldArtwork: true,
                                type: ArtworkType.AUDIO,
                                artworkBorder: BorderRadius.zero,

                                //If the artwork or the song has no illustration
                                nullArtworkWidget: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: MusicPlayerTheme()
                                          .primaryDefaultArtworkBackgroundColor,
                                    ),
                                    child: const Icon(
                                      Icons.music_note_sharp,
                                      color: Colors.white,
                                    )),
                              ),
                              title: SizedBox(
                                height: 18,
                                child: currentSongTitle.length > 20
                                    ? Marquee(
                                        text: (currentSongTitle)
                                                .replaceAll('_', ' ') +
                                            ('      '),
                                        style: TextStyle(
                                            color: MusicPlayerTheme()
                                                .selectedTile),
                                        fadingEdgeStartFraction: 0.2,
                                        fadingEdgeEndFraction: 0.2,
                                        scrollAxis: Axis.horizontal,
                                      )
                                    : Text(
                                        currentSongTitle,
                                        style: TextStyle(
                                            color: MusicPlayerTheme()
                                                .selectedTile),
                                        maxLines: 1,
                                      ),
                              ),
                              subtitle: Text(
                                currentArtist ?? "No Artist",
                                style: TextStyle(
                                    color: MusicPlayerTheme().secondaryColor),
                                maxLines: 1,
                              ),
                              trailing: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isPlaying
                                      ? IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              isPlaying = !isPlaying;
                                            });
                                            await _player.pause();
                                          },
                                          icon: Icon(
                                            Icons.pause,
                                            color: MusicPlayerTheme().iconColor,
                                          ),
                                        )
                                      : IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              isPlaying = !isPlaying;
                                            });
                                            await _player.play();
                                          },
                                          icon: Icon(
                                            Icons.play_arrow,
                                            color: MusicPlayerTheme().iconColor,
                                          )),
                                  IconButton(
                                      onPressed: () async {
                                        setState(() {
                                          isQueue = true;
                                          isHome = false;
                                          isSearch = false;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.queue_music,
                                        color: MusicPlayerTheme().iconColor,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        StreamBuilder<DurationState>(
                            stream: _durationStateStream,
                            builder: (context, snapshot) {
                              final durationState = snapshot.data;
                              final progress =
                                  durationState?.position ?? Duration.zero;
                              final total =
                                  durationState?.total ?? Duration.zero;

                              return ProgressBar(
                                thumbRadius: 0,
                                progress: progress,
                                total: total,
                                barHeight: 3.0,
                                timeLabelTextStyle:
                                    const TextStyle(color: Colors.transparent),
                                baseBarColor:
                                    MusicPlayerTheme().progressBaseColor,
                                progressBarColor:
                                    MusicPlayerTheme().progressBarColor,
                                thumbColor: Colors.transparent,
                              );
                            }),
                      ],
                    )
                  : WillPopScope(
                      //Overrides Back button
                      onWillPop: () async {
                        setState(() {
                          isTapped = !isTapped;
                        });
                        return false;
                      },
                      child: SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: MusicPlayerTheme().linearGradientBody,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () {
                                          setState(() {
                                            isTapped = !isTapped;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.expand_more_outlined,
                                          size: 30,
                                          color: MusicPlayerTheme().iconColor,
                                        )),
                                    IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            isShuffle = !isShuffle;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  isShuffle
                                                      ? 'Shuffle On'
                                                      : 'Shuffle Off',
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 14.0),
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin: const EdgeInsets.only(
                                                    bottom: 80,
                                                    left: 30,
                                                    right: 30),
                                                duration: const Duration(
                                                    milliseconds: 600),
                                                backgroundColor:
                                                    const Color.fromARGB(
                                                        131, 64, 66, 88),
                                                elevation: 0,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    20.0))),
                                              ),
                                            );
                                          });
                                          await _player
                                              .setShuffleModeEnabled(isShuffle);
                                        },
                                        icon: Icon(
                                          Icons.shuffle_rounded,
                                          color: isShuffle
                                              ? Colors.white
                                              : Colors.grey,
                                        )),
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 60, bottom: 45),
                                  height: 250,
                                  width: 250,
                                  child: QueryArtworkWidget(
                                    id: currentSongID,
                                    keepOldArtwork: true,
                                    type: ArtworkType.AUDIO,
                                    artworkBorder: BorderRadius.zero,

                                    //If the artwork or the song has no illustration
                                    nullArtworkWidget: Container(
                                        padding: const EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: MusicPlayerTheme()
                                              .primaryDefaultArtworkBackgroundColor,
                                        ),
                                        child: const Icon(
                                          Icons.music_note_sharp,
                                          color: Colors.white,
                                          size: 120,
                                        )),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        currentSongTitle.replaceAll('_', ' '),
                                        style: TextStyle(
                                            color:
                                                MusicPlayerTheme().primaryColor,
                                            fontSize: 20),
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        currentArtist ?? "No Artist",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: MusicPlayerTheme()
                                                .secondaryColor),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 55,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: StreamBuilder<DurationState>(
                                      stream: _durationStateStream,
                                      builder: (context, snapshot) {
                                        final durationState = snapshot.data;
                                        final progress =
                                            durationState?.position ??
                                                Duration.zero;
                                        final total = durationState?.total ??
                                            Duration.zero;

                                        return ProgressBar(
                                          onSeek: (duration) {
                                            _player.seek(duration);
                                          },
                                          progress: progress,
                                          total: total,
                                          barHeight: 6.0,
                                          thumbRadius: 8,
                                          timeLabelLocation:
                                              TimeLabelLocation.sides,
                                          timeLabelTextStyle: TextStyle(
                                              color: MusicPlayerTheme()
                                                  .primaryColor),
                                          baseBarColor: MusicPlayerTheme()
                                              .progressBaseColor,
                                          progressBarColor: MusicPlayerTheme()
                                              .progressBarColor,
                                          thumbColor: MusicPlayerTheme()
                                              .progressBarColor,
                                        );
                                      }),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        onPressed: () async {
                                          await _player.seekToPrevious();
                                        },
                                        icon: const Icon(Icons.skip_previous,
                                            size: 40, color: Colors.white)),
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    isPlaying
                                        ? IconButton(
                                            onPressed: () async {
                                              setState(() {
                                                isPlaying = !isPlaying;
                                              });
                                              await _player.pause();
                                            },
                                            icon: Icon(
                                              Icons.pause,
                                              color:
                                                  MusicPlayerTheme().iconColor,
                                              size: 40,
                                            ),
                                          )
                                        : IconButton(
                                            onPressed: () async {
                                              setState(() {
                                                isPlaying = !isPlaying;
                                              });
                                              await _player.play();
                                            },
                                            icon: Icon(
                                              Icons.play_arrow,
                                              color:
                                                  MusicPlayerTheme().iconColor,
                                              size: 40,
                                            )),
                                    const SizedBox(
                                      width: 30,
                                    ),
                                    IconButton(
                                        onPressed: () async {
                                          await _player.seekToNext();
                                        },
                                        icon: const Icon(Icons.skip_next,
                                            size: 40, color: Colors.white)),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            )
          : null,
    );
  }

  ConcatenatingAudioSource createPlaylist(List<SongModel>? songs) {
    List<AudioSource> sources = [];

    for (var song in songs!) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }

    return ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: sources,
    );
  }

  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (songs.isNotEmpty) {
        currentSongTitle = songs[index].title;
        currentIndex = index;
        currentSongID = songs[index].id;
        currentArtist = songs[index].artist;
        isPlaying = true;
      }
    });
  }
}

class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}
