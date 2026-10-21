/// Локализация статусов коннектора OCPP 2.0.1 для UI.
String connectorStatusRu(String? status) {
  switch (status?.trim()) {
    case 'Available':
      return 'Свободен';
    case 'Occupied':
      return 'Занят';
    case 'Reserved':
      return 'Зарезервирован';
    case 'Unavailable':
      return 'Недоступен';
    case 'Faulted':
      return 'Неисправен';
    case null:
    case '':
      return 'Неизвестно';
    default:
      return status!;
  }
}
