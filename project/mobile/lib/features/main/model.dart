class MainModel {
  MainModel({this.tabIndex = 0});

  final int tabIndex;

  MainModel copyWith({int? tabIndex}) => MainModel(tabIndex: tabIndex ?? this.tabIndex);
}
