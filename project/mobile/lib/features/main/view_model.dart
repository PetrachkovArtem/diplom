import 'package:charging_app/core/base/base_view_model.dart';
import 'package:charging_app/features/main/model.dart';
import 'package:charging_app/services/session_hub.dart';

class MainViewModel extends BaseViewModel<MainModel> {
  MainViewModel({SessionHubService? hub})
      : _hub = hub ?? SessionHubServiceManager.instance,
        super(MainModel()) {
    _hub.connect();
  }

  final SessionHubService _hub;

  void setTab(int index) {
    state = state.copyWith(tabIndex: index);
  }

  @override
  void dispose() {
    _hub.disconnect();
    super.dispose();
  }
}
