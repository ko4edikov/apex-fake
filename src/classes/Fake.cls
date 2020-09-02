/**
* <p>Class for creating fake records and ability to populating parent and child records</p>
*/
public class Fake {
	private final static FakeIdFactory ID_FACTORY = new FakeIdFactory();

	private final SObjectType sObjectType;
	public final Map<String, Object> values;
	private final Id fakeId;

	/**
	* <p>Construct fake record from class type</p>
	* <p>Usage</p>
	* <p><code>new Fake(Account.class)</p>
	*
	* @param type type of Object to fake
	*/
	public Fake(final Type type) {
		this(((SObject)type.newInstance()).getSObjectType());
	}

	/**
	* <p>Construct fake record from SObject type</p>
	* <p>Usage</p>
	* <p><code>new Fake(Account.getSObjectType())</p>
	*
	* @param sObjectType type of SObject to fake
	*/
	public Fake(final SObjectType sObjectType) {
		this.sObjectType = sObjectType;
		this.values = this.putAttributes();
		this.fakeId = ID_FACTORY.generate(this.sObjectType);

		this.putField('Id', this.fakeId);
	}

	/**
	* <p>Construct fake record from other SObject, copying field values</p>
	* <p>Usage</p>
	* <p><code>new SimpleFake(new Account(Name = 'test'))</p>
	*
	* @param record record of SObject to fake
	*/
	public Fake(final SObject record) {
		this.sObjectType = record.getSObjectType();
		this.values = record.getPopulatedFieldsAsMap().clone();
		this.fakeId = ID_FACTORY.generate(this.sObjectType);

		this.putField('Id', this.fakeId);
	}

	/**
	* <p>Adds a RecordType by Name to current fake</p>
	*
	* @param name RecordType.Name for current Fake
	 *
	 * @return this Fake.class record
	*/
	public Fake putRecordTypeByName(final String name) {
		final RecordTypeInfo rtInfo = this.sObjectType.getDescribe().getRecordTypeInfosByName().get(name);
		if (rtInfo == null) {
			throw new FakeException('No RecordType with Name ' + name + ' found for ' + this.sObjectType);
		}
		return this.putRecordType(rtInfo);
	}

	/**
	* <p>Adds a RecordType by DeveloperName to current fake</p>
	*
	* @param developerName RecordType.DeveloperName for current Fake
	 *
	 * @return this Fake.class record
	*/
	public Fake putRecordTypeByDeveloperName(final String developerName) {
		final RecordTypeInfo rtInfo = this.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(developerName);
		if (rtInfo == null) {
			throw new FakeException('No RecordType with DeveloperName ' + developerName + ' found for ' + this.sObjectType);
		}
		return this.putRecordType(rtInfo);
	}

	/**
	* <p>Adds a field to current fake</p>
	*
	* @param field field name
	* @param value field value
	 *
	 * @return this Fake.class record
	*/
	public Fake putField(final String field, final Object value) {
		final SObjectField sObjectField = this.getSObjectField(field);
		return this.putField(sObjectField, value);
	}

	/**
	* <p>Adds a field to current fake</p>
	*
	* @param sObjectField field token e.g. Account.Name
	* @param value field value
	 *
	 * @return this Fake.class record
	*/
	public Fake putField(final SObjectField sObjectField, final Object value) {
		this.values.put('' + sObjectField, value);
		return this;
	}

	/**
	* <p>Adds a parent fake record to this fake record</p>
	*
	* @param field name of the parent field e.g. 'AccountId' for Contact
	* @param parentRecord parent record
	*
	* @return this Fake.class record
	*/
	public Fake putParent(final String field, final SObject parentRecord) {
		return this.putParent(field, new Fake(parentRecord));
	}

	/**
	* <p>Adds a parent fake record to this fake record</p>
	*
	* @param field name of the parent field e.g. 'AccountId' for Contact
	* @param parentFake parent fake record
	*
	* @return this Fake.class record
	*/
	public Fake putParent(final String field, final Fake parentFake) {
		final SObjectField sObjectField = this.getSObjectField(field);
		return this.putParent(sObjectField, parentFake);
	}

	/**
	* <p>Adds a parent fake record to this fake record</p>
	*
	* @param sObjectField name of the parent field e.g. Account.AccountId for Contact
	* @param parentFake parent fake record
	*
	* @return this Fake.class record
	*/
	public Fake putParent(final SObjectField sObjectField, final Fake parentFake) {
		final SObject parent = parentFake.build();

		final String parentLookup = sObjectField.getDescribe().getRelationshipName();
		final String parentLookupId = sObjectField.getDescribe().getName();
		if (parentLookup == null) {
			throw new FakeException(sObjectField + ' is not a lookup field for ' + this.sObjectType);
		}
		this.values.put(parentLookupId, parent.Id);
		this.values.put(parentLookup, parent);
		return this;
	}

	/**
	* <p>Adds a list of fake child record to this fake record</p>
	*
	* @param relationshipName relationship name for children
	* @param childFakes list of child fakes
	*
	* @return this Fake.class record
	*/
	public Fake putChildren(final String relationshipName, final List<Fake> childFakes) {
		try {
			final ChildRelationship childRelationship = this.getChildRelationship(relationshipName);
			final String childLookupName = '' + childRelationship.getField();
			final Map<String, Object> builtChildren = new FakeChildren(childFakes).build(childLookupName, this.fakeId);

			this.values.put(relationshipName, builtChildren);
		} catch (Exception ex) {
			throw new FakeException('No relationship ' + relationshipName + ' found for ' + this.sObjectType);
		}
		return this;
	}

	/**
	* <p>Adds a list of fake child record to this fake record</p>
	*
	* @param relationshipName relationship name for children
	* @param records list of child SObject records
	*
	* @return this Fake.class record
	*/
	public Fake putChildren(final String relationshipName, final List<SObject> records) {
		for (SObject record : records) {
			this.putChild(relationshipName, record);
		}
		return this;
	}

	/**
	* <p>Adds a fake child record to this fake record</p>
	*
	* @param relationshipName relationship name for children
	* @param childFake child fake
	*
	* @return this Fake.class record
	*/
	public Fake putChild(final String relationshipName, final Fake childFake) {
		if ( ! this.values.containsKey(relationshipName)) {
			return this.putChildren(relationshipName, new List<Fake>{childFake});
		}
		final Map<String, Object> children =  (Map<String, Object>) this.values.get(relationshipName);
		((List<Object>)(children.get('records'))).add(childFake.build());
		children.put('totalSize', (Integer) children.get('totalSize') + 1);
		return this;
	}

	/**
	* <p>Adds a fake child record to this fake record</p>
	*
	* @param relationshipName relationship name for children
	* @param record child SObject record
	*
	* @return this Fake.class record
	*/
	public Fake putChild(final String relationshipName, final SObject record) {
		this.putChild(relationshipName, new Fake(record));
		return this;
	}

	/**
	* <p>Performs final building of the fake object to SObject</p>
	*
	* @return built SObject
	*/
	public SObject build() {
		try {
			final String jsonifiedSObject = JSON.serialize(this.values);
			return (SObject) JSON.deserialize(jsonifiedSObject, Type.forName('' + this.sObjectType));
		} catch (Exception ex) {
			throw new FakeException(ex);
		}
	}

	public Fake preview() {
		System.debug('\n Preview => ' + this);
		return this;
	}

	public override String toString() {
		return 'SObjectType: ' + this.sObjectType + ',\n' +
			' fieldValByName : ' + this.values + ',\n' +
			' fakeId : ' + this.fakeId + ',\n'
			;
	}

	/**
	* <p>Retrieves a child relationship for the relationship name of current SObject type</p>
	*
	* @param relationshipName name of the relationship between two SObjects, e.g Account -> (relName: Contacts) <- [Contact]
	*
	* @return an instance Schema.ChildRelationship.class
	*/
	private ChildRelationship getChildRelationship(final String relationshipName) {
		for (ChildRelationship relationship : this.sObjectType.getDescribe().getChildRelationships()) {
			if(relationship.getRelationshipName() == relationshipName) {
				return relationship;
			}
		}
		return null;
	}

	/**
	* <p>Sets up a required type attribute to the fake record</p>
	*
	* @return new values for fake object
	*/
	private Map<String, Object> putAttributes() {
		final Map<String, Object> attributes = new Map<String, Object>();
		attributes.put(
			'attributes' , new Map<String, String>{
				'type' => '' + this.sObjectType
			});

		return attributes;
	}

	/**
	* <p>Adds record type as parent with populated DeveloperName, Name and Id to current fake</p>
	*
	* @param rtInfo name of the relationship between two SObjects, e.g Account -> (relName: Contacts) <- [Contact]
	*
	* @return this Fake.class record
	*/
	private Fake putRecordType(final RecordTypeInfo rtInfo) {
		final Fake fake = new Fake(RecordType.class)
			.putField('DeveloperName', rtInfo.getDeveloperName())
			.putField('Name', rtInfo.getName())
			.putField('Id', rtInfo.getRecordTypeId());
		this.putParent('RecordTypeId', fake);
		return this;
	}

	/**
	* <p>Retrieves SObjectField by field name from current SObjectType</p>
	* <p>If field doesn't exist throws an error 'No field <fieldName> found on the <sobjectType>' </p>
	*
	* @param field name of the relationship between two SObjects, e.g Account -> (relName: Contacts) <- [Contact]
	*
	* @return an instance Schema.SObjectField.class
	*/
	private SObjectField getSObjectField(final String field) {
		this.checkSObjectField(field);
		return this.sObjectType.getDescribe().fields.getMap().get(field);
	}

	/**
	* <p>Checks if field exists on current SObjectType</p>
	* <p>and throws an error 'No field <fieldName> found on the <sobjectType>' if field doesn't exist</p>
	*
	* @param field name of the relationship between two SObjects, e.g Account -> (relName: Contacts) <- [Contact]
	*/
	private void checkSObjectField(final String field) {
		if (this.sObjectType.getDescribe().fields.getMap().containsKey(field)) { return; }
		throw new FakeException('No field ' + field + ' found on the ' + this.sObjectType);

	}


	/**
	* Produces new fake Ids
	*/
	private class FakeIdFactory {
		private Integer fakeIdCount = 0;
		private final String ID_PATTERN = '000000000000';

		private Id generate(final SObjectType sObjectType) {
			fakeIdCount++;
			final String keyPrefix = sObjectType.getDescribe().getKeyPrefix();
			final String fakeIdPrefix = ID_PATTERN.substring(0, 12 - fakeIdCount.format().length());
			return Id.valueOf(keyPrefix + fakeIdPrefix + fakeIdCount);
		}
	}


	/**
	* Contains a list of fake children and build them into a list of "real" children SObjects
	*/
	private class FakeChildren {
		private List<Fake> childFakes = new List<Fake>();

		private FakeChildren(final List<Fake> childFakes) {
			this.childFakes = childFakes;
		}

		public Map<String, Object> build(final String field, final Id parentId) {
			final Map<String, Object> result = new Map<String, Object>{
				'totalSize' => this.childFakes.size(),
				'done' => true,
				'records' => new List<SObject>()
			};
			for (Fake fake : this.childFakes) {
				fake.putField(field, parentId);
				((List<SObject>)(result.get('records'))).add(fake.build());
			}
			return result;
		}
	}

	public class FakeException extends Exception {}
}