library common_tests;

import "package:redstone_mapper/mapper.dart";
import 'package:unittest/unittest.dart';

import "domain.dart";

installCommonTests() {

  group("Encode:", () {

    test("Simple object", () {

      var obj = createSimpleObj();

      var data = encode(obj);

      expect(data, equals({
          "value1": "str",
          "value2": 10,
          "value3": true,
          "value4": dateTest.toIso8601String()
      }));

    });

    test("Complex object", () {

      var obj = createComplexObj();

      var data = encode(obj);

      expect(data, equals({
          "value1": "str",
          "value2": 10,
          "value3": true,
          "value4": dateTest.toIso8601String(),
          "innerObj": {
              "innerObjValue": "obj1"
          },
          "innerObjs": [
              {"innerObjValue": "obj2"},
              {"innerObjValue": "obj3"}
          ]
      }));
    });

    test("List", () {

      var list = [createSimpleObj(), createSimpleObj()];

      var data = encode(list);
      var expected = {
          "value1": "str",
          "value2": 10,
          "value3": true,
          "value4": dateTest.toIso8601String()
      };

      expect(data, equals([expected, expected]));

    });

  });

  group("Decode:", () {

    test("Simple object", () {

      var obj = createSimpleObj();

      var data = {
          "value1": "str",
          "value2": 10,
          "value3": true,
          "value4": dateTest.toIso8601String()
      };

      var decoded = decode(data, TestObj);

      expect(decoded, equals(obj));
    });

    test("Complex object", () {

      var obj = createComplexObj();

      var data = {
          "value1": "str",
          "value2": 10,
          "value3": true,
          "value4": dateTest.toIso8601String(),
          "innerObj": {
              "innerObjValue": "obj1"
          },
          "innerObjs": [
              {"innerObjValue": "obj2"},
              {"innerObjValue": "obj3"}
          ]
      };

      var decoded = decode(data, TestComplexObj);

      expect(decoded, equals(obj));
    });

    test("List", () {

      var data = {
          "value1": "str",
          "value2": 10,
          "value3": true,
          "value4": dateTest.toIso8601String(),
          "innerObj": {
              "innerObjValue": "obj1"
          },
          "innerObjs": [
              {"innerObjValue": "obj2"},
              {"innerObjValue": "obj3"}
          ]
      };

      var list = [data, data];

      var decoded = decode(list, TestComplexObj);

      expect(decoded, equals([createComplexObj(), createComplexObj()]));
    });
  });

  group("Validator:", () {

    test("using validator object", () {
      var validator = new Validator(TestObj)
        ..add("value1", const Matches(r'\w+'))
        ..add("value2", const Range(min: 9, max: 12))
        ..add("value3", const NotEmpty());

      var testObj = createSimpleObj();
      expect(validator.execute(testObj), isNull);

      testObj.value1 = ",*[";
      testObj.value2 = 2;
      testObj.value3 = null;

      var invalidFields = {
          "value1": ["matches"],
          "value2": ["range"],
          "value3": ["notEmpty"]
      };

      expect(validator.execute(testObj).invalidFields, equals(invalidFields));
    });

    test("using schema", () {
      var obj = new TestValidator()
        ..value1 = "str"
        ..value2 = 10
        ..value3 = true;

      expect(obj.validate(), isNull);

      obj.value1 = ",*[";
      obj.value2 = 2;
      obj.value3 = null;

      var invalidFields = {
          "value1": ["matches"],
          "value2": ["range"],
          "value3": ["notEmpty"]
      };

      expect(obj.validate().invalidFields, equals(invalidFields));
    });

  });

}