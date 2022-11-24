import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_plugin_record_plus/const/play_state.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_base.dart';
import 'package:tencent_cloud_chat_uikit/base_widgets/tim_ui_kit_state.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/separate_models/tui_chat_separate_view_model.dart';
import 'package:tencent_cloud_chat_uikit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tencent_cloud_chat_uikit/data_services/message/message_services.dart';
import 'package:tencent_cloud_chat_uikit/data_services/services_locatar.dart';
import 'package:tencent_cloud_chat_uikit/ui/constants/history_message_constant.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/color.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/platform.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tencent_cloud_chat_uikit/ui/utils/sound_record.dart';

import 'TIMUIKitMessageReaction/tim_uikit_message_reaction_show_panel.dart';

class TIMUIKitSoundElem extends StatefulWidget {
  final V2TimMessage message;
  final V2TimSoundElem soundElem;
  final String msgID;
  final bool isFromSelf;
  final int? localCustomInt;
  final bool isShowJump;
  final VoidCallback? clearJump;
  final TextStyle? fontStyle;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? textPadding;
  final bool? isShowMessageReaction;
  final TUIChatSeparateViewModel chatModel;

  const TIMUIKitSoundElem(
      {Key? key,
      required this.soundElem,
      required this.msgID,
      required this.isFromSelf,
      this.isShowJump = false,
      this.clearJump,
      this.localCustomInt,
      this.fontStyle,
      this.borderRadius,
      this.backgroundColor,
      this.textPadding,
      required this.message,
      this.isShowMessageReaction,
      required this.chatModel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _TIMUIKitSoundElemState();
}

class _TIMUIKitSoundElemState extends TIMUIKitState<TIMUIKitSoundElem> {
  final int charLen = 8;
  bool isPlaying = false;
  StreamSubscription<Object>? subscription;
  bool isShowJumpState = false;
  bool isShining = false;
  final TUIChatGlobalModel globalModel = serviceLocator<TUIChatGlobalModel>();
  final MessageService _messageService = serviceLocator<MessageService>();
  late V2TimSoundElem stateElement = widget.message.soundElem!;

  _playSound() async {
    if (!SoundPlayer.isInited) {
      // bool hasMicrophonePermission = await Permissions.checkPermission(
      //     context, Permission.microphone.value);
      // bool hasStoragePermission = isIosDevice ||
      //     await Permissions.checkPermission(context, Permission.storage.value);
      // if (!hasMicrophonePermission || !hasStoragePermission) {
      //   return;
      // }
      SoundPlayer.initSoundPlayer();
    }
    if (widget.localCustomInt == null ||
        widget.localCustomInt != HistoryMessageDartConstant.read) {
      globalModel.setLocalCustomInt(widget.msgID,
          HistoryMessageDartConstant.read, widget.chatModel.conversationID);
    }
    if (isPlaying) {
      SoundPlayer.stop();
      widget.chatModel.currentSelectedMsgId = "";
    } else {
      SoundPlayer.play(url: stateElement.url!);
      widget.chatModel.currentSelectedMsgId = widget.msgID;
      // SoundPlayer.setSoundInterruptListener(() {
      //   // setState(() {
      //   isPlaying = false;
      //   // });
      // });
    }
  }

  downloadMessageDetailAndSave() async {
    if (widget.message.msgID != null && widget.message.msgID != '') {
      if (widget.message.soundElem!.url == null ||
          widget.message.soundElem!.url == '') {
        final response = await _messageService.getMessageOnlineUrl(
            msgID: widget.message.msgID!);
        widget.message.soundElem = response.data!.soundElem;
        Future.delayed(const Duration(microseconds: 10), () {
          setState(() => stateElement = response.data!.soundElem!);
        });
      }
      if (!PlatformUtils().isWeb) {
        if (widget.message.soundElem!.localUrl == null ||
            widget.message.soundElem!.localUrl == '') {
          _messageService.downloadMessage(
              msgID: widget.message.msgID!,
              messageType: 4,
              imageType: 0,
              isSnapshot: false);
        }
      }
    }
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      isPlaying = widget.chatModel.currentSelectedMsgId != '' &&
          widget.chatModel.currentSelectedMsgId == widget.msgID;
    });
  }

  @override
  void initState() {
    super.initState();
    subscription = SoundPlayer.playStateListener(listener: (PlayState data) {
      if (data.playState == 'complete') {
        widget.chatModel.currentSelectedMsgId = "";
        // SoundPlayer.removeSoundInterruptListener();
      }
    });
    downloadMessageDetailAndSave();
  }

  @override
  void dispose() {
    if (isPlaying) {
      SoundPlayer.stop();
      widget.chatModel.currentSelectedMsgId = "";
    }
    subscription?.cancel();
    super.dispose();
  }

  double _getSoundLen() {
    double soundLen = 32;
    if (stateElement.duration != null) {
      final realSoundLen = stateElement.duration!;
      int sdLen = 32;
      if (realSoundLen > 10) {
        sdLen = 12 * charLen + ((realSoundLen - 10) * charLen / 0.5).floor();
      } else if (realSoundLen > 2) {
        sdLen = 2 * charLen + realSoundLen * charLen;
      }
      sdLen = min(sdLen, 20 * charLen);
      soundLen = sdLen.toDouble();
    }

    return soundLen;
  }

  _showJumpColor() {
    if ((widget.chatModel.jumpMsgID != widget.message.msgID) &&
        (widget.message.msgID?.isNotEmpty ?? true)) {
      return;
    }
    isShining = true;
    int shineAmount = 6;
    setState(() {
      isShowJumpState = true;
    });
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          isShowJumpState = shineAmount.isOdd ? true : false;
        });
      }
      if (shineAmount == 0 || !mounted) {
        isShining = false;
        timer.cancel();
      }
      shineAmount--;
    });
    widget.clearJump!();
  }

  @override
  Widget tuiBuild(BuildContext context, TUIKitBuildValue value) {
    final theme = value.theme;
    final backgroundColor = widget.isFromSelf
        ? theme.lightPrimaryMaterialColor.shade50
        : theme.weakBackgroundColor ?? CommonColor.weakBackgroundColor;
    final borderRadius = widget.isFromSelf
        ? const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(2),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10))
        : const BorderRadius.only(
            topLeft: Radius.circular(2),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10));
    if (widget.isShowJump) {
      if (!isShining) {
        Future.delayed(Duration.zero, () {
          _showJumpColor();
        });
      } else {
        if ((widget.chatModel.jumpMsgID == widget.message.msgID) &&
            (widget.message.msgID?.isNotEmpty ?? false)) {
          widget.clearJump!();
        }
      }
    }
    return InkWell(
      onTap: () => _playSound(),
      child: Container(
        padding: widget.textPadding ?? const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isShowJumpState
              ? const Color.fromRGBO(245, 166, 35, 1)
              : (widget.backgroundColor ?? backgroundColor),
          borderRadius: widget.borderRadius ?? borderRadius,
        ),
        constraints: const BoxConstraints(maxWidth: 240),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.isFromSelf
                  ? [
                      Container(width: _getSoundLen()),
                      Text(
                        "''${stateElement.duration} ",
                        style: widget.fontStyle,
                      ),
                      isPlaying
                          ? Image.asset(
                              'images/play_voice_send.gif',
                              package: 'tencent_cloud_chat_uikit',
                              width: 16,
                              height: 16,
                            )
                          : Image.asset(
                              'images/voice_send.png',
                              package: 'tencent_cloud_chat_uikit',
                              width: 16,
                              height: 16,
                            ),
                    ]
                  : [
                      isPlaying
                          ? Image.asset(
                              'images/play_voice_receive.gif',
                              package: 'tencent_cloud_chat_uikit',
                              width: 16,
                              height: 16,
                            )
                          : Image.asset(
                              'images/voice_receive.png',
                              width: 16,
                              height: 16,
                              package: 'tencent_cloud_chat_uikit',
                            ),
                      Text(
                        " ${stateElement.duration}''",
                        style: widget.fontStyle,
                      ),
                      Container(width: _getSoundLen()),
                    ],
            ),
            if (widget.isShowMessageReaction ?? true)
              TIMUIKitMessageReactionShowPanel(
                message: widget.message,
              )
          ],
        ),
      ),
    );
  }
}
