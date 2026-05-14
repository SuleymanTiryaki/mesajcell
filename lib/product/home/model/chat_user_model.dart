import 'package:flutter/material.dart';
import 'package:mesajcell/features/utility/const/constant_color.dart';

class ChatUser {
  final String name;
  final String lastMessage;
  final String time;
  final String avatarInitials;
  final Color avatarColor;
  final int unreadCount;

  const ChatUser({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatarInitials,
    required this.avatarColor,
    this.unreadCount = 0,
  });
}

// TODO: API'den çekilecek, mock data
final List<ChatUser> mockUsers = [
  ChatUser(
    name: 'Ahmet Yılmaz',
    lastMessage: 'Yarın görüşürüz 👋',
    time: '09:45',
    avatarInitials: 'AY',
    avatarColor: ConstColor.avatarBlue,
    unreadCount: 2,
  ),
  ChatUser(
    name: 'Zeynep Kaya',
    lastMessage: 'Tamam, anlıyorum.',
    time: 'Dün',
    avatarInitials: 'ZK',
    avatarColor: ConstColor.avatarPurple,
  ),
  ChatUser(
    name: 'Mehmet Demir',
    lastMessage: 'Dosyayı gönderdim.',
    time: 'Dün',
    avatarInitials: 'MD',
    avatarColor: ConstColor.avatarGreen,
    unreadCount: 5,
  ),
  ChatUser(
    name: 'Elif Şahin',
    lastMessage: 'Harika! Görüşürüz 😊',
    time: 'Pazartesi',
    avatarInitials: 'EŞ',
    avatarColor: ConstColor.avatarOrange,
  ),
  ChatUser(
    name: 'Can Arslan',
    lastMessage: 'Nerede buluşuyoruz?',
    time: 'Pazar',
    avatarInitials: 'CA',
    avatarColor: ConstColor.avatarTeal,
  ),
  ChatUser(
    name: 'Ayşe Çelik',
    lastMessage: 'Evet, uygun.',
    time: '12.05.2026',
    avatarInitials: 'AÇ',
    avatarColor: ConstColor.avatarRed,
  ),
];
