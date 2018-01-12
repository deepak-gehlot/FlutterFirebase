class PostItem {

  String description;
  String postImage;
  int timestamp;
  String userEmail;
  String userId;
  String userImage;
  String userName;
  String key;
  int likeCount;
  int shareCount;
  int commentCount;

  PostItem(this.key, this.description, this.postImage, this.timestamp,
      this.userEmail,
      this.userId, this.userImage, this.userName, this.likeCount,
      this.shareCount, this.commentCount);

}