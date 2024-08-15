import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:dcard/model/check_card_model.dart';
import 'package:dcard/model/event_detail_model.dart';
import 'package:dcard/model/event_model.dart';
import 'package:dcard/network/auth_header.dart';
import 'package:dcard/network/dio_client.dart';
import 'package:dcard/network/dio_exception.dart';
import 'package:dcard/network/endpoints.dart';
import 'package:dcard/widget/custom_snackbar.dart';
import 'package:dcard/widget/toast_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventRepository {
  get context => null;

  /**
   * Fetch all Events
   */

  Future<List<EventDatum>> fetchEventLists() async {
    print("*************************");
    print('hello');
    print('****************');
    try {
      final headers = await ApiHeader().authHeader();
      final response = await DioClient.instance.get(
        eventsListED,
        options: Options(headers: headers),
      );
      final List<EventDatum> loadedEventList = [];

      response['data'].forEach((value) {
        loadedEventList.add(EventDatum.fromJson(value));
      });
      return loadedEventList.toList();
    } on DioError catch (e) {
      var error = DioException.fromDioError(e);
      throw error.errorMessage;
    }
  }

/**
 * Fetch event
 */

  Future<EventDetail> fetchEvent(String id) async {
    try {
      final headers = await ApiHeader().authHeader();
      final response = await DioClient.instance.get(
        '$eventDetailED$id',
        options: Options(headers: headers),
      );
      final eventDetail = EventDetail.fromJson(response['data']);
      return eventDetail;
    } on DioError catch (e) {
      if (e.response != null) {
        throw e.response!.data['message'];
      } else {
        var error = DioException.fromDioError(e);
        throw error.errorMessage;
      }
    }
  }

  /**
   * Event Scan card
   */

  Future<dynamic> scanCard(dynamic data) async {
    try {
      final headers = await ApiHeader().authHeader();
      final response = await DioClient.instance.post(
        eventScanCardED,
        data: data,
        options: Options(headers: headers),
      );

      var result = CheckCardModel.fromJson(response);

      return result;
    } on DioError catch (e) {
      if (e.response != null) {
        throw e.response!.data['message'];
      } else {
        var error = DioException.fromDioError(e);
        throw error.errorMessage;
      }
    }
  }
}
