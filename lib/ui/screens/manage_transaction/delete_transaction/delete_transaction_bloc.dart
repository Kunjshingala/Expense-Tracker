import 'package:expense_tracker/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

import '../../../../modals/firebase_modal/transaction_modal.dart';
import '../../../../utils/finance_calculation.dart';
import '../../../../utils/finance_overview_reader.dart';
import '../../../../utils/firebase_references.dart';
import '../../../../utils/transaction_removal.dart';
import '../../../common_view/snack_bar.dart';

class DeleteTransactionBloc {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseDatabase realtimeDatabase = FirebaseDatabase.instance;
  FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  final deleteTransactionProcessStatusSubject = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get getDeleteTransactionProcessStatus => deleteTransactionProcessStatusSubject.stream;

  Function(bool) get setDeleteTransactionProcessStatus => deleteTransactionProcessStatusSubject.add;

  /// Removes [transaction] everywhere it is stored. Returns whether it went
  /// through, so the caller can close its sheet only on success.
  Future<bool> onDelete(TransactionModal transaction) async {
    setDeleteTransactionProcessStatus(true);

    try {
      await deleteData(transaction);

      /// only once the records are gone, so a failed write never orphans the
      /// transaction from its attachment.
      await deleteAttachment(transaction);

      showMySnackBar(message: languages.transactionDeletedSuccessfully, messageType: MessageType.success);
      debugPrint('onDelete---------------------------------->Complete');
      return true;
    } on FirebaseException catch (e) {
      debugPrint('onDelete----------------------------------> on FirebaseException catch (e) $e');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      return false;
    } catch (e) {
      debugPrint('onDelete----------------------------------> catch (e) $e');
      showMySnackBar(message: languages.somethingWentWrong, messageType: MessageType.failed);
      return false;
    } finally {
      setDeleteTransactionProcessStatus(false);
    }
  }

  /// Firebase realtime database.
  Future<void> deleteData(TransactionModal transaction) async {
    /// Main Ref.
    final rtDatabaseRef = realtimeDatabase
        .ref()
        .child(FirebaseRealTimeDatabaseRef.users)
        .child(auth.currentUser!.uid)
        .child(FirebaseRealTimeDatabaseRef.transactions);

    final date = parseTransactionDate(transaction.date);

    final dayOverviewRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child(date.monthKey)
        .child(FirebaseRealTimeDatabaseRef.dayWiseTransactions)
        .child(date.day)
        .child(FirebaseRealTimeDatabaseRef.dayFinanceOverview);

    final monthOverviewRef = rtDatabaseRef
        .child(FirebaseRealTimeDatabaseRef.monthWiseTransactions)
        .child(date.monthKey)
        .child(FirebaseRealTimeDatabaseRef.summary)
        .child(FirebaseRealTimeDatabaseRef.monthFinanceOverview);

    /// read the totals this transaction still counts towards.
    final dayOverview = await readDayFinanceOverview(dayOverviewRef);
    final monthOverview = await readMonthFinanceOverview(monthOverviewRef);

    /// one atomic write: the five removals and the two corrected totals land
    /// together, so the summaries can never drift out of step with the list.
    await rtDatabaseRef.update(
      transactionRemovalUpdates(
        transaction: transaction,
        dayOverview: dayOverview,
        monthOverview: monthOverview,
      ),
    );

    debugPrint('deleteData---------------------------------->Done');
  }

  /// Firebase Storage.
  Future<void> deleteAttachment(TransactionModal transaction) async {
    if (transaction.imageUrl == null) return;

    final storageRef = firebaseStorage
        .ref()
        .child(FirebaseStorageRef.users)
        .child(auth.currentUser!.uid)
        .child(transaction.id)
        .child('${transaction.id}.jpg');

    /// a missing or already deleted object should not fail the delete; the
    /// database records are gone by this point either way.
    try {
      await storageRef.delete();
      debugPrint('deleteAttachment---------------------------------->file deleted successfully');
    } on FirebaseException catch (e) {
      debugPrint('deleteAttachment---------------------------------->$e');
    } catch (e) {
      debugPrint('deleteAttachment---------------------------------->$e');
    }
  }

  void dispose() {
    deleteTransactionProcessStatusSubject.close();
  }
}
