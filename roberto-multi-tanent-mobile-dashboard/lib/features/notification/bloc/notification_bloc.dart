import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:roberto/features/notification/bloc/notification_event.dart';
import 'package:roberto/features/notification/bloc/notification_state.dart';
import 'package:roberto/features/notification/data/repositories/notification_repository.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository}) : super(NotificationInitial()) {
    on<FetchNotificationsRequested>(_onFetchNotificationsRequested);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
  }

  Future<void> _onFetchNotificationsRequested(
    FetchNotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading(notifications: state.notifications, unreadCount: state.unreadCount));
    try {
      final response = await notificationRepository.getNotifications();
      emit(NotificationLoaded(
        notifications: response.notifications,
        unreadCount: response.unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(
        message: e.toString(),
        notifications: state.notifications,
        unreadCount: state.unreadCount,
      ));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    // Optimistic UI update
    final currentNotifications = state.notifications.map((n) {
      return n.copyWith(isRead: true);
    }).toList();
    
    emit(NotificationLoaded(notifications: currentNotifications, unreadCount: 0));

    try {
      await notificationRepository.markAllAsRead();
    } catch (e) {
      // If error, we might want to fetch again to restore state
      emit(NotificationError(
        message: e.toString(),
        notifications: state.notifications,
        unreadCount: state.unreadCount,
      ));
      add(FetchNotificationsRequested());
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    // Optimistic UI update
    int newUnreadCount = state.unreadCount;
    final currentNotifications = state.notifications.map((n) {
      if (n.id == event.notificationId && !n.isRead) {
        newUnreadCount = (newUnreadCount > 0) ? newUnreadCount - 1 : 0;
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();

    emit(NotificationLoaded(notifications: currentNotifications, unreadCount: newUnreadCount));

    try {
      await notificationRepository.markAsRead(event.notificationId);
    } catch (e) {
      emit(NotificationError(
        message: e.toString(),
        notifications: state.notifications,
        unreadCount: state.unreadCount,
      ));
      add(FetchNotificationsRequested());
    }
  }
}
