# Protocol Buffers

Google 的数据交换格式，平台无关、语言无关。Protocol Buffers 是一个将结构化数据编码成高效可扩展的方式。

这个可视化的话和 JSON 比较像，还是挺容易理解的，本身感觉没多少可写的。下面直接上例子：

## AddressBook

```
// addressbook.proto
package tutorial;

message Person {
  required string name = 1;
  required int32 id = 2;
  optional string email = 3;

  enum PhoneType {
    MOBILE = 0;
    HOME = 1;
    WORK = 2;
  }

  message PhoneNumber {
    required string number = 1;
    optional PhoneType type = 2 [default = HOME];
  }

  repeated PhoneNumber phone = 4;
}

message AddressBook {
  repeated Person person = 1;
}
```

用 Protocol Buffers C++ 编译器来编译它会生成两个文件`addressbook.pb.h`和`addressbook.pb.cc`。

```
$ protoc -I=$SRC_DIR --cpp_out=$DST_DIR $SRC_DIR/addressbook.proto
```

每个 message 都会生成一个对应的类，也就是说以内容会生成三个类，分别叫`Person`，`Person_PhoneNumber`和`AddressBook`。

`Person`这个类里主要有以下函数：

```
// name
inline bool has_name() const;
inline void clear_name();
inline const ::std::string& name() const;
inline void set_name(const ::std::string& value);
inline void set_name(const char* value);
inline ::std::string* mutable_name();

// id
inline bool has_id() const;
inline void clear_id();
inline int32_t id() const;
inline void set_id(int32_t value);

// email
inline bool has_email() const;
inline void clear_email();
inline const ::std::string& email() const;
inline void set_email(const ::std::string& value);
inline void set_email(const char* value);
inline ::std::string* mutable_email();

// phone
inline int phone_size() const;
inline void clear_phone();
inline const ::google::protobuf::RepeatedPtrField< ::tutorial::Person_PhoneNumber >& phone() const;
inline ::google::protobuf::RepeatedPtrField< ::tutorial::Person_PhoneNumber >* mutable_phone();
inline const ::tutorial::Person_PhoneNumber& phone(int index) const;
inline ::tutorial::Person_PhoneNumber* mutable_phone(int index);
inline ::tutorial::Person_PhoneNumber* add_phone();
```

### 基本类型的函数

* has_attr() 判断是否存在
* clear_attr() 清空
* attr() 获取其值
* set_attr() 赋值
* mutable_attr() string类型专用，保险的获取其值，当没设置时直接返回空串

### 嵌套类型的函数

* attr_size() 数组（列表）大小
* clear_attr() 清空数组
* attr() 循环时获取其值
* mutable_attr() 循环时保险的获取其值
* attr(int index) 获取索引值
* mutable_attr(int index) 保险的获取索引值
* add_attr() 添加一个元素

## 调用

```
#include <iostream>
#include <fstream>
#include <string>
#include "addressbook.pb.h"
using namespace std;

// This function fills in a Person message
tutorial::Person* SetAddress(tutorial::Person* person) {
  int id = 1;
  person->set_id(id);

  string email = "abc@gmail.com";
  person->set_email(email);

  for(int i = 0; i < 5; i++) {
    string number = std::to_string(i) + "-1234567";
    tutorial::Person::PhoneNumber* phone_number = person->add_phone();
    phone_number->set_number(number);
    phone_number->set_type(tutorial::Person::MOBILE);
  }

  return person;
}

// This function output a Person message
void ListPerson(const tutorial::AddressBook& address_book) {
  for (int i = 0; i < address_book.person_size(); i++) {
    const tutorial::Person& person = address_book.person(i);
    cout << "Person ID: " << person.id() << endl;
    cout << "  Name: " << person.name() << endl;

    for (int j = 0; j < person.phone_size(); j++) {
      const tutorial::Person::PhoneNumber& phone_number = person.phone(j);
      cout << phone_number.number() << endl;
    }
  }
}

int main() {
  // Verify that the version of the library that we linked against is
  // compatible with the version of the headers we compiled against.
  GOOGLE_PROTOBUF_VERIFY_VERSION;


  tutorial::AddressBook address_book;
  person = address_book.add_person();

  {
    // Write the new address book to disk.
    fstream output("/tmp/address_book.data", ios::out | ios::trunc | ios::binary);
    if (!address_book.SerializeToOstream(&output)) {
      cerr << "Failed to write address book." << endl;
      return -1;
    }
  }

  tutorial::AddressBook address_book2;
  {
    // Read the existing address book.
    fstream input("/tmp/address_book.data", ios::in | ios::binary);
    if (!address_book2.ParseFromIstream(&input)) {
      cerr << "Failed to parse address book." << endl;
      return -1;
    }
  }

  ListPerson(address_book2);

  // Optional:  Delete all global objects allocated by libprotobuf.
  google::protobuf::ShutdownProtobufLibrary();

  return 0;
}
```

## 编码

我大致看了一下，还没到可以详细写出来的地步，所以请自己参阅文档。

Encoding Reference: <https://developers.google.com/protocol-buffers/docs/encoding>
