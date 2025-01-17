import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shrine/function/comment.dart';
import 'package:shrine/function/editstory.dart';
import 'package:shrine/function/storystruct.dart';
import 'package:shrine/provider/churchProvider.dart';
import 'package:shrine/provider/like_provider.dart';
import 'package:shrine/provider/login_provider.dart';

class PostContainer extends StatelessWidget {
  final Story post;

  const PostContainer({Key? key, required this.post}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PostHeader(post: post),
                post.userimgUrl != null
                    ? const SizedBox.shrink()
                    : const SizedBox(height: 6.0),
              ],
            ),
          ),
          if (post.contentimgUrl != "") ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Image.network(post.contentimgUrl),
            )
          ] else ...[
            const SizedBox.shrink(),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: _PostStats(post: post),
          )
        ],
      ),
    );
  }
}

class _PostStats extends StatelessWidget {
  final Story post;
  const _PostStats({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late bool liked;
    final churchprovider = Provider.of<ChurchProvider>(context, listen:false);
    final loginprovider = Provider.of<LoginProvider>(context, listen: false);
    final Likeprovider = Provider.of<LikeProvider>(context, listen: false);
    if(post.likeUserList.contains(loginprovider.user.uid)){
       Likeprovider.setLiked();
    }
    else{
       Likeprovider.setdisLiked();
    }
    liked = Likeprovider.isliked;
    int num = post.likeUsers;
    return Consumer<LikeProvider>(
      builder: (context,appState,_){
        return Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: (){
                    if(liked == false){
                      //post.likeUserList.add(loginprovider.user.uid);
                      appState.addLike(loginprovider.user.uid, churchprovider.church.id, post.docid);
                      liked = !liked;
                      num = num + 1;
                    }
                    else{
                      //post.likeUserList.remove(loginprovider.user.uid);
                      appState.deleteLike(loginprovider.user.uid, churchprovider.church.id, post.docid);
                      liked = !liked;
                      num = num - 1;
                    }
                  },
                  icon: liked ? const Icon(
                    Icons.favorite,
                    size: 25.0,
                    color: Colors.green,
                  ):
                  const Icon(
                    Icons.favorite_border_rounded,
                    size: 25.0,
                    color: Colors.green,
                  )
                ),
                const SizedBox(width: 9.0),
                IconButton(
                  icon: Icon(
                  Icons.mode_comment_outlined,
                  size: 22.0,
                  color: Colors.green,
                ), onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CommentPage(
                            docid: post.docid,
                            userimg: post.userimgUrl,
                            content: post.content,
                            username: post.username),
                      ));
                },)
                /*Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child:
                ),*/
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Text(
                  "좋아요 " + num.toString() + "개",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.username,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(child: Text(post.content)),
              ],
            )
          ],
        );
      }
    );
  }
}

class _PostHeader extends StatefulWidget {
  final Story post;
  const _PostHeader({Key? key, required this.post}) : super(key: key);

  @override
  __PostHeaderState createState() => __PostHeaderState();
}

class __PostHeaderState extends State<_PostHeader> {

  @override
  Widget build(BuildContext context) {
    final churchprovider = Provider.of<ChurchProvider>(context, listen:false);
    final loginprovider = Provider.of<LoginProvider>(context, listen: false);
    return Row(
      children: [
        ProfileAvatar(imageUrl: widget.post.userimgUrl),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.username,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    widget.post.updatetime,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12.0,
                    ),
                  ),
                  Icon(
                    Icons.public,
                    color: Colors.grey[600],
                    size: 12.0,
                  )
                ],
              )
            ],
          ),
        ),
        if(widget.post.uid == loginprovider.user.uid)...[
          PopupMenuButton<String>(
            icon: Icon(Icons.more_horiz),
            onSelected: (String result) {
              setState(() {
                if(result == "삭제"){
                  FirebaseFirestore.instance.collection('church').doc(churchprovider.church.id).collection('infostory').doc(widget.post.docid).delete();
                }
                if(result == "수정"){
                  Navigator.push(context,MaterialPageRoute(builder: (context) => editPage(post: widget.post)));
                }
              });
            },
            itemBuilder: (BuildContext context) => <String>["삭제","수정"]
                .map((value) => PopupMenuItem(
              value: value,
              child: Text(value),
            ))
                .toList(),
          ),
        ]
      ],
    );
  }
}

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  const ProfileAvatar({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20.0,
      backgroundColor: Colors.grey[600],
      backgroundImage: NetworkImage(imageUrl),
    );
  }
}

