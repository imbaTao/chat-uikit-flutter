import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat/components/tencent_cloud_chat_components_utils.dart';
import 'package:tencent_cloud_chat/data/basic/tencent_cloud_chat_basic_data.dart';
import 'package:tencent_cloud_chat/tencent_cloud_chat.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_state_widget.dart';
import 'package:tencent_cloud_chat_common/base/tencent_cloud_chat_theme_widget.dart';

class TencentCloudChatConversationAppBar extends StatefulWidget {
  final TextEditingController? textEditingController;

  const TencentCloudChatConversationAppBar({
    super.key,
    this.textEditingController,
  });

  @override
  State<StatefulWidget> createState() => TencentCloudChatConversationAppBarState();
}

class TencentCloudChatConversationAppBarState extends TencentCloudChatState<TencentCloudChatConversationAppBar> {
  final Stream<TencentCloudChatBasicData<dynamic>>? _basicDataStream =
  TencentCloudChat.instance.eventBusInstance.on<TencentCloudChatBasicData<dynamic>>("TencentCloudChatBasicData");
  StreamSubscription<TencentCloudChatBasicData<dynamic>>? _basicDataSubscription;

  bool includeSearch =
      TencentCloudChat.instance.dataInstance.basic.usedComponents.contains(TencentCloudChatComponentsEnum.search);

  @override
  void initState() {
    super.initState();
    _addBasicEventListener();
  }

  void _addBasicEventListener() {
    _basicDataSubscription = _basicDataStream?.listen((event) {
      if (event.currentUpdatedFields == TencentCloudChatBasicDataKeys.addUsedComponent) {
       safeSetState(() {
         includeSearch =
             TencentCloudChat.instance.dataInstance.basic.usedComponents.contains(TencentCloudChatComponentsEnum.search);
       });
      }
    });
  }

  @override
  Widget tabletAppBuilder(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: desktopBuilder(context),
    );
  }

  @override
  Widget defaultBuilder(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: getWidth(15)),
      child: const TencentCloudChatConversationAppBarName(),
    );
  }

  @override
  Widget desktopBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
      build: (context, colorTheme, textStyle) => Container(
        padding: EdgeInsets.symmetric(
          vertical: getHeight(11.4),
          horizontal: getWidth(16),
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: colorTheme.dividerColor,
            ),
          ),
        ),
        child: (widget.textEditingController != null && includeSearch)
            ? TencentCloudChatAppBarSearchItem(
                textEditingController: widget.textEditingController!,
              )
            : Text(
                tL10n.chats,
                style: TextStyle(
                  color: colorTheme.settingTitleColor,
                  fontSize: textStyle.fontsize_24 + 4,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

class TencentCloudChatConversationAppBarName extends StatefulWidget {
  const TencentCloudChatConversationAppBarName({super.key});

  @override
  State<StatefulWidget> createState() => TencentCloudChatConversationAppBarNameState();
}

class TencentCloudChatConversationAppBarNameState
    extends TencentCloudChatState<TencentCloudChatConversationAppBarName> {
  addContacts() {}

  newMessage() {}

  @override
  Widget defaultBuilder(BuildContext context) {
    return TencentCloudChatThemeWidget(
        build: (context, colorTheme, textStyle) => Row(
              children: [
                Container(
                  width: getWidth(8),
                ),
                Expanded(
                    child: Text(
                  tL10n.chat,
                  style: TextStyle(
                      color: colorTheme.contactItemFriendNameColor,
                      fontSize: textStyle.fontsize_34,
                      fontWeight: FontWeight.w600),
                )),
                IconButton(
                  icon: Icon(Icons.brightness_medium, color: colorTheme.appBarIconColor),
                  onPressed: () {
                    TencentCloudChat.instance.chatController.toggleBrightnessMode();
                  },
                ),
              ],
            ));
  }
}

class TencentCloudChatAppBarSearchItem extends StatefulWidget {
  final TextEditingController textEditingController;

  const TencentCloudChatAppBarSearchItem({Key? key, required this.textEditingController}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TencentCloudChatAppBarSearchItemState();
}

class TencentCloudChatAppBarSearchItemState extends State<TencentCloudChatAppBarSearchItem> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLines: 1,
      controller: widget.textEditingController,
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        hintText: tL10n.search,
        filled: true,
        isDense: true,
        hintStyle: const TextStyle(fontSize: 12),
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.textEditingController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    widget.textEditingController.clear();
                  });
                },
              )
            : null,
        border: const OutlineInputBorder(borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(0),
      ),
      onChanged: (value) {
        setState(() {});
      },
    );
  }
}
