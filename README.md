# Apex-fake
Library to create mocked objects for Stub API

## Use cases
The class helps to create fake object records without insert into the database.
It's helpful if you use Stub API for unit test creation.

The benefit of an object mocking is the ability to populate formula fields without 
populating dependent fields that formula includes.


## References
-[Creating new fake](#Creating-new-fake)  
-[Populating fields](#Populating-fields)  
-[Populating RecordType](#Populating-RecordType)  
-[Populating parent](#Populating-parent)  
-[Populating child](#Populating-child)  
-[Populating children](#Populating-children)  
-[Results](#Results)  






### Creating new fake
```apex
    new Fake(Account.class);
    new Fake(Account.SObjectType());
    new Fake(Account.getSObjectType());
```


### Populating fields 
```apex
    new Fake(Account.class).putField('Name', 'Test Account');
    new Fake(Account.class).putField(Account.Name, 'Test Account');
```


### Populating RecordType
```apexpex
    new Fake(Account.class).putRecordTypeByName('Account Record Type Name');
    new Fake(Account.class).putRecordTypeByDevName('Account_Record_Type_Developer_Name');

```
If record type will not found the exception will be thrown:
```
Fake.InvalidRecordTypeException: RT with Developer Name 'Account_Record_Type_Developer_Name' doesn't exist for SObject: Account
```
### Populating parent
```apex
    new Fake(Contact.class).putParent('AccountId', new Fake(Account.class));
    new Fake(Contact.class).putParent('AccountId', (Account) new Fake(Account.class).build());

```

### Populating child
```apex
    new Fake(Account.class).putChild('Contacts', new Fake(Contact.class));
    new Fake(Account.class).putChild('Contacts', (Contact) new Fake(Contact.class).build());
```

### Populating children
```apex
    new Fake(Account.class).putChildren('Contacts', new List<Contact>{
        (Contact) new Fake(Contact.class).build(),
        (Contact) new Fake(Contact.class).build(),
        (Contact) new Fake(Contact.class).build()
    });
```
### Results
```apex
    new Fake(Account.class).preview();

    //Fake SObjectType: Account , relationshipName :  , fieldValByName : {
    //    "Id" : "001000000000001AAA",
    //    "attributes" : {
    //      "type" : "Account"
    //    }
    //  } , parentFakeByLookupName : {}

    (Account) new Fake(Account.class).build();

    //{
    //  "attributes" : {
    //    "type" : "Account",
    //    "url" : "/services/data/v48.0/sobjects/Account/001000000000001AAA"
    //  },
    //  "Id" : "001000000000001AAA"
   //}  

```

