import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongQueue extends StatefulWidget {
  final List<SongModel> songs;
  final String currentSongTitle;
  final String? currentArtist;

  final int currentIndex;
  final int currentSongID;
  const SongQueue(
      {super.key,
      required this.songs,
      required this.currentSongTitle,
      this.currentArtist,
      required this.currentIndex,
      required this.currentSongID});

  @override
  State<SongQueue> createState() => _SongQueueState();
}

class _SongQueueState extends State<SongQueue> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text('Song Queue'),
      ),
      body: ListView.builder(
          itemCount: widget.songs.length,
          itemBuilder: ((context, index) {
            return ListTile(
              trailing: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.currentSongID == widget.songs[index].id)
                    const MiniMusicVisualizer(
                      color: Colors.red,
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

              title: widget.currentSongID == widget.songs[index].id
                  ? SizedBox(
                      height: 15,
                      child: Marquee(
                        text: (widget.songs[index].title).replaceAll('_', ' '),
                        style: TextStyle(color: Colors.red),
                        scrollAxis: Axis.horizontal,
                      ),
                    )
                  : SizedBox(
                      height: 20,
                      child: Text(
                        (widget.songs[index].title).replaceAll('_', ' '),
                        maxLines: 1,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
              subtitle: Text(widget.songs[index].artist ?? "No Artist"),

              //Retrieve the song illustration
              leading: QueryArtworkWidget(
                id: widget.songs[index].id,
                type: ArtworkType.AUDIO,
                artworkBorder: BorderRadius.zero,
                keepOldArtwork: true,

                //If the artwork or the song has no illustration
                nullArtworkWidget: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.grey,
                    ),
                    child: const Icon(
                      Icons.music_note_sharp,
                      color: Colors.white,
                    )),
              ),
            );
          })),
    );
  }
}
