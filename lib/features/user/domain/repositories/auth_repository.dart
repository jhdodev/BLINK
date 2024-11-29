import 'dart:math';

import 'package:blink/core/utils/result.dart';
import 'package:blink/features/user/data/models/user_model.dart';
import 'package:blink/features/user/domain/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository implements UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // users 컬렉션 참조
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // 회원가입 및 사용자 정보 저장
  Future<Result> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // 1. Firebase Auth로 계정 생성
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. 이메일 인증 보내기 (선택사항)
      await credential.user?.sendEmailVerification();

      // 3. 생성된 계정에 닉네임 설정
      await credential.user?.updateDisplayName(name);

      final nicName = await generateUniqueNickname();

      // 4. UserModel 생성
      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        nickname: nicName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Firestore 저장
      await _usersCollection.doc(user.id).set(user.toMap());

      return Result.success("회원가입이 완료되었습니다. 이메일 인증 진행 후 로그인 해주세요.");
    } catch (e) {
      return Result.failure("error : ${e.toString()}");
    }
  }

  // 로그인
  Future<DataResult<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 이메일 인증 확인
      if (!userCredential.user!.emailVerified) {
        return DataResult.failure("이메일 인증이 필요합니다. 이메일을 확인해주세요.");
      }

      // 로그인된 사용자의 uid 가져오기
      final id = userCredential.user?.uid;
      if (id == null) {
        return DataResult.failure("사용자 ID를 가져올 수 없습니다.");
      }

      // Firestore에서 사용자 정보 가져오기
      final userDoc = await _usersCollection.doc(id).get();

      if (!userDoc.exists) {
        return DataResult.failure("사용자 정보를 찾을 수 없습니다.");
      }

      // 문서 데이터를 UserModel로 변환
      final userData = userDoc.data() as Map<String, dynamic>;
      final userModel = UserModel.fromJson(userData);

      return DataResult.success(userModel, "로그인에 성공했습니다.");
    } catch (e) {
      return DataResult.failure("로그인에 실패했습니다. error : $e");
    }
  }

  // 사용자 정보 가져오기 (UserRepository 인터페이스 구현)
  @override
  Future<UserModel> getUserById(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception("사용자 정보를 찾을 수 없습니다.");
    }
    return UserModel.fromJson(userDoc.data()!);
  }

  // 사용자 정보 가져오기
  Future<UserModel?> getUserDataWithUserId(String userId) async {
    try {
      final docSnapshot = await _usersCollection.doc(userId).get();

      if (!docSnapshot.exists) {
        throw Exception("사용자 정보를 찾을 수 없습니다.");
      }

      final data = docSnapshot.data() as Map<String, dynamic>?;

      if (data == null) {
        throw Exception("사용자 데이터가 비어 있습니다.");
      }

      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception("사용자 정보를 가져오는 중 오류가 발생했습니다: $e");
    }
  }

  // 사용자 정보 업데이트
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _usersCollection.doc(userId).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // 현재 사용자의 마지막 접속 시간 업데이트
      final user = _auth.currentUser;
      if (user != null) {
        await _usersCollection.doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
      }
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // 회원 탈퇴
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Firestore에서 사용자 데이터 삭제
        await _usersCollection.doc(user.uid).delete();
        // Auth에서 사용자 삭제
        await user.delete();
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<String> generateUniqueNickname() async {
    while (true) {
      final random = Random();
      final randomNumber = random.nextInt(9000) + 1000;
      final nickname = 'Blink$randomNumber';

      // Firestore에서 닉네임 중복 체크
      final docSnapshot = await _firestore
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .get();

      if (docSnapshot.docs.isEmpty) {
        return nickname;
      }
    }
  }
}
