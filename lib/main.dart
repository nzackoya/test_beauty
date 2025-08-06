import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp(repository: SessionRepository()));
}

class Session {
  Session(this.date, this.customer, this.amount);

  final DateTime date;
  final String customer;
  final int amount;
}

class SessionRepository {
  // Dates: 1 <= n <= 365
  // Clients: 1 <= m <= 1000
  Future<List<Session>> fetch() {
    return Future.value([
      Session(DateTime(2025, 7, 1), 'Customer A', 100),
      Session(DateTime(2025, 7, 1), 'Customer B', 200),
      Session(DateTime(2025, 7, 1), 'Customer C', 300),
      Session(DateTime(2025, 7, 2), 'Customer D', 300),
      Session(DateTime(2025, 7, 2), 'Customer E', 300),
      Session(DateTime(2025, 7, 2), 'Customer F', 300),
      Session(DateTime(2025, 7, 2), 'Customer A', 300),
      Session(DateTime(2025, 7, 3), 'Customer B', 300),
    ]);
  }
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.repository});

  final SessionRepository repository;

  final formattedDate = DateFormat('EEEE, MMMM d, yyyy');

  final mainColor = Color(0xffEDECEE);

  final titleFont = TextStyle(fontWeight: FontWeight.bold, fontSize: 12);
  final totalFont = TextStyle(fontSize: 12);
  final amountFont = TextStyle(fontSize: 10);
  final customerFont = TextStyle(fontSize: 13);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        backgroundColor: mainColor,
        body: SafeArea(
          child: FutureBuilder(
            future: SessionRepository().fetch(),
            builder: (context, snapshot) {
              final elements = snapshot.data ?? [];
              return GroupedListView<Session, String>(
                padding: EdgeInsets.all(10),
                elements: elements,
                groupBy: (element) => formattedDate.format(element.date),
                groupSeparatorBuilder: (String groupByValue) {
                  return titleWidget(groupByValue);
                },
                separator: Divider(height: 1, color: mainColor),
                groupItemBuilder: (context, session, groupStart, groupEnd) {
                  final rowItem = rowItemWidget(
                    session: session,
                    groupStart: groupStart,
                    groupEnd: groupEnd,
                  );
                  return !groupEnd
                      ? rowItem
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            rowItem,
                            totalRowWidget(
                              elements: elements,
                              session: session,
                            ),
                          ],
                        );
                },
                sort: false,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget titleWidget(String groupByValue) {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 3, top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Date', style: titleFont),
          Text(groupByValue, style: titleFont),
        ],
      ),
    );
  }

  Widget rowItemWidget({
    required Session session,
    required bool groupStart,
    required bool groupEnd,
  }) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(groupStart ? 8.0 : 0),
          topRight: Radius.circular(groupStart ? 8.0 : 0),
          bottomLeft: Radius.circular(groupEnd ? 8.0 : 0),
          bottomRight: Radius.circular(groupEnd ? 8.0 : 0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(session.customer, style: customerFont),
          Text(session.amount.toString(), style: amountFont),
        ],
      ),
    );
  }

  Widget totalRowWidget({
    required List<Session> elements,
    required Session session,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total', style: totalFont),
          Text(
            elements
                .where((val) => val.date == session.date)
                .fold<int>(0, (initial, current) => initial + current.amount)
                .toString(),
            style: totalFont,
          ),
        ],
      ),
    );
  }
}
