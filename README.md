# Apex-fake
Library to create mocked objects for Stub API

## Use cases
The class helps to create fake object records without insert into the database.
It's helpful if you use Stub API for unit test creation.

The benefit of an object mocking is the ability to populate formula fields without 
populating dependent fields that formula includes. You can also create a record with 
filled parents and children.

## Installing

Click on the button below to deploy the component to the org  

[![Deploy](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png)](https://githubsfdeploy.herokuapp.com)

## References
- [Creating new fake](#Creating-new-fake)  
- [Populating fields](#Populating-fields)  
- [Populating RecordType](#Populating-RecordType)  
- [Populating parent](#Populating-parent)  
- [Populating child](#Populating-child)  
- [Populating children](#Populating-children)  
- [Results](#Results)  
- [Examples](#Examples)
- [License](#License)
- [Thanks](#Thanks)


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
```apex
    new Fake(Account.class).putRecordTypeByName('Account Record Type Name');
    new Fake(Account.class).putRecordTypeByDevName('Account_Record_Type_Developer_Name');

```
If record type will not found the exception will be thrown:
```
Fake.FakeException: No RecordType with DeveloperName Account_Record_Type_Developer_Name found for Account
```

### Populating parent
```apex
    new Fake(Contact.class).putParent('AccountId', new Fake(Account.class));
    new Fake(Contact.class).putParent('AccountId', (Account) new Fake(Account.class).build());

```

Also, you can use putParent() to create a fake RecordType if you need, then fake id will be generated:
```apex
    Account account = (Account) new Fake(Account.class)
    	.putParent('RecordTypeId', new Fake(RecordType.class)
    		.putField(RecordType.DeveloperName, 'Fake_RecordType')
    	).build();
```
```apex
/**
    {
      "attributes" : {
        "type" : "Account",
        "url" : "/services/data/v49.0/sobjects/Account/001000000000001AAA"
      },
      "RecordType" : {
        "attributes" : {
          "type" : "RecordType",
          "url" : "/services/data/v49.0/sobjects/RecordType/012000000000002AAA"
        },
        "Id" : "012000000000002AAA",
        "DeveloperName" : "Fake_RecordType"
      },
      "RecordTypeId" : "012000000000002AAA",
      "Id" : "001000000000001AAA"
    }
*/
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

    //Preview => Fake SObjectType: Account , relationshipName :  , fieldValByName : {
    //    "Id" : "001000000000001AAA",
    //    "attributes" : {
    //      "type" : "Account"
    //    }
    //  } , parentFakeByLookupName : {}

    Account acc = (Account) new Fake(Account.class).build();
    System.debug('\n acc => ' + acc + '\n');

    //acc => Account:{Id=001000000000001AAA}

```

### Examples

```apex
    Contact cont = (Contact) new Fake(Contact.class)
    	.putRecordTypeByName('Gold')
    	.putField(Contact.FirstName, 'Ivan')
    	.putField(Contact.LastName, 'Sorokin')
    	.putField(Contact.LastName, 'Sorokin')
    	.putField(Contact.LastModifiedDate, Datetime.now().addMinutes(-2))
    	.putField(Contact.CreatedDate, Datetime.now().addMinutes(-10))
    	.putParent('AccountId', new Fake(Account.class)
    		.putParent('MasterRecordId', new Fake(Account.class)
    			.putParent('MasterRecordId', new Fake(Account.class)
    				.putParent('MasterRecordId', new Fake(Account.class)
    					.putParent('MasterRecordId', new Fake(Account.class)
    					)
    				)
    			)
    		)
    	)
    	.putChild('Shares', new Fake(ContactShare.class)
    		.putField(ContactShare.RowCause, 'Manual')
    		.putField(ContactShare.ContactAccessLevel, 'Edit')
    		.putParent('UserOrGroupId', new Fake(User.class))
    	)
    	.putChildren('Opportunities', new List<SObject>{
    		(Opportunity) new Fake(Opportunity.class).putField(Opportunity.Amount, 44444).build(),
    		(Opportunity) new Fake(Opportunity.class).putField(Opportunity.Amount, 55555).build()
    	})
    	.build();
    
    System.debug('\n cont => ' + JSON.serializePretty(cont) + '\n');
```
###### Result:
```apex
/** 
    cont => {
      "attributes" : {
        "type" : "Contact",
        "url" : "/services/data/v48.0/sobjects/Contact/003000000000001AAA"
      },
      "Account" : {
        "attributes" : {
          "type" : "Account",
          "url" : "/services/data/v48.0/sobjects/Account/001000000000002AAA"
        },
        "Id" : "001000000000002AAA",
        "MasterRecord" : {
          "attributes" : {
            "type" : "Account",
            "url" : "/services/data/v48.0/sobjects/Account/001000000000004AAA"
          },
          "Id" : "001000000000004AAA",
          "MasterRecord" : {
            "attributes" : {
              "type" : "Account",
              "url" : "/services/data/v48.0/sobjects/Account/001000000000005AAA"
            },
            "Id" : "001000000000005AAA",
            "MasterRecord" : {
              "attributes" : {
                "type" : "Account",
                "url" : "/services/data/v48.0/sobjects/Account/001000000000006AAA"
              },
              "Id" : "001000000000006AAA",
              "MasterRecord" : {
                "attributes" : {
                  "type" : "Account",
                  "url" : "/services/data/v48.0/sobjects/Account/001000000000007AAA"
                },
                "Id" : "001000000000007AAA"
              },
              "MasterRecordId" : "001000000000007AAA"
            },
            "MasterRecordId" : "001000000000006AAA"
          },
          "MasterRecordId" : "001000000000005AAA"
        },
        "MasterRecordId" : "001000000000004AAA"
      },
      "LastModifiedDate" : "2020-07-07T08:24:48.957+0000",
      "AccountId" : "001000000000002AAA",
      "RecordType" : {
        "attributes" : {
          "type" : "RecordType",
          "url" : "/services/data/v48.0/sobjects/RecordType/0125J0000000UA2QAM"
        },
        "Id" : "0125J0000000UA2QAM",
        "DeveloperName" : "Gold",
        "Name" : "Gold"
      },
      "FirstName" : "Ivan",
      "CreatedDate" : "2020-07-07T08:16:48.958+0000",
      "RecordTypeId" : "0125J0000000UA2QAM",
      "Opportunities" : {
        "totalSize" : 1,
        "done" : true,
        "records" : [ {
          "attributes" : {
            "type" : "Opportunity",
            "url" : "/services/data/v48.0/sobjects/Opportunity/006000000000011AAA"
          },
          "Amount" : 55555.0,
          "ContactId" : "003000000000001AAA",
          "Id" : "006000000000011AAA"
        } ]
      },
      "LastName" : "Sorokin",
      "Id" : "003000000000001AAA",
      "Shares" : {
        "totalSize" : 1,
        "done" : true,
        "records" : [ {
          "attributes" : {
            "type" : "ContactShare",
            "url" : "/services/data/v48.0/sobjects/ContactShare/03s000000000008AAA"
          },
          "ContactAccessLevel" : "Edit",
          "ContactId" : "003000000000001AAA",
          "Id" : "03s000000000008AAA",
          "RowCause" : "Manual"
        } ]
      }
    }
    

*/

```

### License
MIT

### Thanks
Thanks for the inspiration and advice to [Alex 4an70m](https://github.com/4an70m)
