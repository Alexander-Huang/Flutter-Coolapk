import 'dart:convert';

import 'package:coolapk_flutter/util/anim_page_route.dart';
import 'package:coolapk_flutter/util/html_text.dart';
import 'package:coolapk_flutter/util/level_label.dart';
import 'package:coolapk_flutter/util/show_qr_code.dart';
import 'package:coolapk_flutter/widget/item_adapter/items/items.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

part './feed_type_cover_12_content.dart';
part './feed_type_12_content.dart';
part './feed_type_11_content.dart';
part './feed_type_9_content.dart';
part './feed_type_4_content.dart';
part './feed_type_0_content.dart';
part './feed_footer.dart';
part './feed_header.dart';
part './feed_item_replyrows.dart';
part './feed_item_imagebox.dart';

/// 最难搞的东西
/// source["type"] 有很多
///   0: 普通动态
///   9: 评论 某应用的
///   11: 回答
///   12: 图文
///   13: 视频
class FeedItem extends StatelessWidget {
  final dynamic source;
  const FeedItem({Key key, this.source}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (source["type"].toString()) {
      case "0":
        content = FeedType0Content(source);
        break;
      case "9":
        content = FeedType0Content(source);
        break;
      case "4":
        content = FeedType4Content(source);
        break;
      case "11":
        content = FeedType11Content(source);
        break;
      case "12":
        if (source["entityTemplate"] == "feedCover")
          content = FeedTypeCover12Content(source);
        else
          content = FeedType12Content(source);
        break;
      default:
        content = Text("不支持的content type " + source["type"].toString());
    }
    return MCard(
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.all(16).copyWith(top: 8, bottom: 8),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FeedItemHeader(
            userName: source["username"],
            headImgUrl: source["userAvatar"],
            subTitle1: source["infoHtml"].toString(),
            phoneName: source["device_title"],
            source: source,
          ),
          content,
          const Divider(
            color: Colors.transparent,
            height: 8,
          ),
          buildForwardSourceFeed(source, context),
          buildRelationRow(source, context),
          FeedItemReplyRows(source),
          FeedItemFooter(source),
        ],
      ),
    );
  }
}

Widget buildForwardSourceFeed(
    final dynamic source, final BuildContext context) {
  final sfeed = source["forwardSourceFeed"];
  return sfeed == null
      ? const SizedBox()
      : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
                shape: BoxShape.rectangle,
              ),
              child: HtmlText(
                shrinkToFit: true,
                html: "<a>${sfeed["username"]}: </a>${sfeed["message"]}",
              ),
            ),
          ),
        );
}

Widget buildRelationRow(final dynamic source, final BuildContext context) {
  final List<dynamic> rr = source["relationRows"] ?? [];
  final tr = source["targetRow"];
  if ((rr == null && tr == null) || (tr != null && rr.length == 0)) {
    return const SizedBox(width: 0, height: 0);
  }

  if (tr != null && tr["title"] != null) {
    rr.add(source["targetRow"]);
  }
  return Container(
    padding: const EdgeInsets.only(top: 8, left: 16, right: 8),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: rr.map<Widget>((entity) {
        return Container(
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(4)),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              // TODO: handle this, target -> entity["url"] 可能是/apk/xxx
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  (entity["logo"] != null && entity["logo"].length > 0)
                      ? Padding(
                          padding: const EdgeInsets.only(right: 4.0),
                          child: ExtendedImage.network(
                            entity["logo"],
                            cache: false, // TODO:
                            width: 22,
                            height: 22,
                            filterQuality: FilterQuality.low,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const SizedBox(),
                  Text(entity["title"]),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}
