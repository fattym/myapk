import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

IconData getIconForName(String name) {
  switch (name) {
    case 'school':
      return Icons.school;
    case 'draw':
      return Icons.draw;
    case 'book':
      return Icons.book;
    case 'checkroom':
      return Icons.checkroom;
    case 'science':
      return Icons.science;
    case 'palette':
      return Icons.palette;
    case 'menu-book':
      return Icons.menu_book;
    case 'menu-math':
      return Icons.menu_book;
    case 'language':
      return Icons.language;
    case 'public':
      return Icons.public;
    case 'sports-soccer':
      return Icons.sports_soccer;
    case 'precision':
      return Icons.precision_manufacturing;
    case 'pen':
      return Icons.edit;
    case 'edit':
      return Icons.edit;
    case 'history-edu':
      return Icons.history_edu;
    case 'university':
      return Icons.account_balance;
    case 'book-open':
      return Icons.menu_book;
    case 'gavel':
      return Icons.gavel;
    case 'graduation-cap':
      return Icons.school;
    case 'book-reader':
      return Icons.book;
    case 'math':
      return Icons.calculate;
    default:
      return Icons.star;
  }
}

FaIconData getFaIconForName(String name) {
  switch (name) {
    case 'whatsapp':
      return FontAwesomeIcons.whatsapp;
    case 'camera':
      return FontAwesomeIcons.camera;
    case 'barcode':
      return FontAwesomeIcons.barcode;
    case 'mobile':
      return FontAwesomeIcons.mobileScreenButton;
    case 'money-bill':
      return FontAwesomeIcons.moneyBill;
    case 'university':
      return FontAwesomeIcons.buildingColumns;
    case 'user-group':
      return FontAwesomeIcons.users;
    case 'location-dot':
      return FontAwesomeIcons.locationDot;
    case 'box':
      return FontAwesomeIcons.box;
    case 'tag':
      return FontAwesomeIcons.tag;
    case 'truck':
      return FontAwesomeIcons.truck;
    case 'store':
      return FontAwesomeIcons.store;
    case 'hand-holding-heart':
      return FontAwesomeIcons.handHoldingHeart;
    case 'credit-card':
      return FontAwesomeIcons.creditCard;
    default:
      return FontAwesomeIcons.star;
  }
}
