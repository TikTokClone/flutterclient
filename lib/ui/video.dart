import 'package:flutter/cupertino.dart';
import 'package:flutterclient/main.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<List<Video>> fetchVideos(BuildContext context, {int count = 1}) async {
  QueryResult result = await graphqlClient.value.query(
    QueryOptions(
      documentNode: gql("""
        query GetVideos(\$count: Int) {
          videos(count: \$count) {
            src
            desc
            likes
            comments
            shares
            liked
            sound {
              user {
                name
              }
              desc
            }
            user {
              name
              profilePicture
            }
          }
        }
      """),
      variables: {
        "count": count
      }
    )
  );

  if (result.hasException) {
    throw Exception("Failed to get videos: ${result.exception.toString()}");
  }

  var videosJson = result.data["videos"];
  List<Video> videos = [];

  for (int video = 0; video < videosJson.length; video++) {
    videos.add(Video.fromJson(videosJson[video]));
  }

  return videos;
}

class Video {
  String src, desc;
  int likes, shares, comments;
  bool liked;
  Sound sound;
  User user;

  Video({this.src, this.desc, this.likes, this.shares, this.comments, this.liked, this.sound, this.user});

  factory Video.fromJson(Map<String, dynamic> json) {
    return new Video(
      src: json["src"],
      desc: json["desc"],
      likes: json["likes"],
      shares: json["shares"],
      comments: json["comments"],
      liked: json["liked"],
      sound: Sound.fromJson(json["sound"]),
      user: User.fromJson(json["user"])
    );
  }
}

class Sound {
  String desc;
  User user;

  Sound({this.desc, this.user});

  factory Sound.fromJson(Map<String, dynamic> json) {
    return new Sound(
      desc: json["desc"],
      user: User.fromJson(json["user"])
    );
  }
}

class User {
  String name;
  String displayName;
  String profilePictureUrl;

  User({this.name, this.displayName, this.profilePictureUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return new User(
      name: json["name"],
      displayName: json["displayName"],
      profilePictureUrl: json["profilePicture"]
    );
  }
}