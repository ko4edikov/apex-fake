@IsTest(IsParallel = true)
private class FakeTest {

	@IsTest
	private static void constructorWithTypeArgument_PositiveTest() {
		Account acc = (Account) new Fake(Account.class).build();
		System.assertNotEquals(null, acc.Id);
	}

	@IsTest
	private static void constructorWithSObjectTypeArgument_PositiveTest() {
		Account acc = (Account) new Fake(Account.SObjectType).build();
		System.assertNotEquals(null, acc.Id);
	}

	@IsTest
	private static void putRecordTypeByDevNameException_Test() {
		String rtDevName = 'fakeDevName';
		try{
			Account acc = (Account) new Fake(Account.class)
				.putRecordTypeByDevName(rtDevName)
				.build();

		} catch(Exception e) {
			System.assertEquals('RT with Developer Name ' + '\'' + rtDevName + '\'' + ' doesn\'t exist for SObject: ' + Account.class, e.getMessage());
		}
	}

	@IsTest
	private static void putRecordTypeByNameException_Test() {
		String rtName = 'fakeName';
		try{
			Account acc = (Account) new Fake(Account.class)
				.putRecordTypeByName(rtName)
				.build();

		} catch(Exception e) {
			System.assertEquals('Fake.InvalidRecordTypeException', e.getTypeName());
			System.assertEquals('RT with Name ' + '\'' + rtName + '\'' + ' doesn\'t exist for SObject: ' + Account.class, e.getMessage());
		}
	}

	@IsTest
	private static void putFieldWithStringArgument_PositiveTest() {
		Account acc = (Account) new Fake(Account.class)
			.putField('Name', 'Field Value')
			.build();
		System.assertEquals('Field Value', acc.Name);
	}

	@IsTest
	private static void putFieldWithStringArgument_NegativeTest() {
		String fieldName = 'FakeFieldName';
		try {
			Account acc = (Account) new Fake(Account.class)
				.putField(fieldName, 'Test Name')
				.build();
		} catch (Exception e) {
			System.assertEquals('Fake.InvalidFieldException', e.getTypeName());
			System.assertEquals(Account.class + ' has not field with name ' + '\'' + fieldName + '\'', e.getMessage());
		}
	}

	@IsTest
	private static void putFieldWithSObjectFieldArgument_PositiveTest() {
		Account acc = (Account) new Fake(Account.class)
			.putField(Account.Name, 'Field Value')
			.build();
		System.assertEquals('Field Value', acc.Name);
	}

	@IsTest
	private static void putParentWithFakeArgument_PositiveTest() {
		Contact cont = (Contact) new Fake(Contact.class)
			.putParent('AccountId', new Fake(Account.class))
			.build();
		System.assertNotEquals(null, cont.Account.Id);
	}

	@IsTest
	private static void putParentWithFakeArgument_NegativeTest() {
		String fieldName = 'LastName';
		try {
			Contact cont = (Contact) new Fake(Contact.class)
				.putParent(fieldName, new Fake(Account.class))
				.build();
		} catch( Exception e) {
			System.assertEquals('Fake.InvalidFieldException', e.getTypeName());
			System.assertEquals('Field with name ' + '\'' + fieldName + '\' is not a lookup field for SObject ' + Contact.class, e.getMessage());
		}
	}

	@IsTest
	private static void putParentWithFakeArgument_2_NegativeTest() {
		String fieldName = 'fakeField';
		try {
			Contact cont = (Contact) new Fake(Contact.class)
				.putParent(fieldName, new Fake(Account.class))
				.build();
		} catch( Exception e) {
			System.assertEquals('Fake.InvalidFieldException', e.getTypeName());
			System.assertEquals(Contact.class + ' has not field with name ' + '\'' + fieldName + '\'', e.getMessage());
		}
	}

	@IsTest
	private static void putParentWithSObjectArgument_PositiveTest() {
		Contact cont = (Contact) new Fake(Contact.class)
			.putParent('AccountId', new Fake(Account.class).build())
			.build();
		System.assertNotEquals(null, cont.Account.Id);
	}

	@IsTest
	private static void putParentWithSObjectArgument_NegativeTest() {
		String fieldName = 'Name';
		try {
			Contact cont = (Contact) new Fake(Contact.class)
				.putParent(fieldName, new Fake(Account.class).build())
				.build();
		} catch( Exception e) {
			System.assertEquals('Fake.InvalidFieldException', e.getTypeName());
			System.assertEquals('Field with name ' + '\'' + fieldName + '\' is not a lookup field for SObject ' + Contact.class, e.getMessage());
		}
	}

	@IsTest
	private static void putParentWithSObjectArgument_2_NegativeTest() {
		String fieldName = 'fakeField';
		try {
			Contact cont = (Contact) new Fake(Contact.class)
				.putParent(fieldName, new Fake(Account.class).build())
				.build();
		} catch( Exception e) {
			System.assertEquals('Fake.InvalidFieldException', e.getTypeName());
			System.assertEquals(Contact.class + ' has not field with name ' + '\'' + fieldName + '\'', e.getMessage());
		}
	}

	@IsTest
	private static void putChildWithFakeArgument_PositiveTest() {
		Account acc = (Account) new Fake(Account.class)
			.putChild('Contacts', new Fake(Contact.class))
			.build();
		System.assertEquals(1, acc.Contacts.size());
		System.assertEquals(acc.Id, acc.Contacts[0].AccountId);
	}

	@IsTest
	private static void putChildWithFakeArgument_NegativeTest() {
		String childRelationshipName = 'fakeChildRelName';
		try {
			Account acc = (Account) new Fake(Account.class)
				.putChild(childRelationshipName, new Fake(Contact.class))
				.build();
		}catch (Exception e) {
			System.assertEquals('Fake.InvalidChildRelationshipException', e.getTypeName());
			System.assertEquals(Account.class + ' doesn\'t contain Child Relationship with name ' + '\'' + childRelationshipName + '\'', e.getMessage());
		}
	}

	@IsTest
	private static void putChildWithSObjectArgument_PositiveTest() {
		Account acc = (Account) new Fake(Account.class)
			.putChild('Contacts', new Fake(Contact.class).build())
			.build();
		System.assertEquals(1, acc.Contacts.size());
		System.assertEquals(acc.Id, acc.Contacts[0].AccountId);
	}

	@IsTest
	private static void putChildWithSObjectArgument_NegativeTest() {
		String childRelationshipName = 'fakeChildRelName';
		try {
			Account acc = (Account) new Fake(Account.class)
				.putChild(childRelationshipName, new Fake(Contact.class).build())
				.build();
		}catch (Exception e) {
			System.assertEquals('Fake.InvalidChildRelationshipException', e.getTypeName());
			System.assertEquals(Account.SObjectType + ' doesn\'t contain Child Relationship with name ' + '\'' + childRelationshipName + '\'', e.getMessage());
		}
	}

	@IsTest
	private static void putChildren_PositiveTest() {
		Contact contact1 = (Contact) new Fake(Contact.class).build();
		Contact contact2 = (Contact) new Fake(Contact.class).build();
		List<Contact> contacts = new List<Contact>{ contact1, contact2 };
		Account acc = (Account) new Fake(Account.class)
			.putChildren('Contacts', contacts)
			.build();
		System.assertEquals(2, acc.Contacts.size());
	}

	@IsTest
	private static void preview_Test() {
		Fake accFake = new Fake(Account.class);
		accFake.toString();
		System.assertEquals(accFake, accFake.preview());
	}

	@IsTest
	private static void toString_Test() {
		Fake accFake = new Fake(Account.class);
		accFake.toString();
	}


}