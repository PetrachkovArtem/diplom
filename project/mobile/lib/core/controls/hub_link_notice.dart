import 'package:charging_app/core/palette.dart';
import 'package:charging_app/services/session_hub.dart';
import 'package:flutter/material.dart';

class HubLinkNotice extends StatelessWidget {
  const HubLinkNotice({super.key, required this.child});

  final Widget child;

  static const message = 'Нет связи с сервером. Данные на экране могут быть устаревшими.';

  @override
  Widget build(BuildContext context) {
    final hub = SessionHubServiceManager.instance;
    return StreamBuilder<HubLink>(
      stream: hub.link,
      initialData: hub.linkState,
      builder: (context, snapshot) {
        final lost = snapshot.data == HubLink.lost;
        final page = lost
            ? MediaQuery.removePadding(context: context, removeTop: true, child: child)
            : child;
        return Column(
          children: [
            if (lost)
              const Material(
                color: AppPalette.danger,
                child: SafeArea(
                  bottom: false,
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        message,
                        style: TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(child: page),
          ],
        );
      },
    );
  }
}
