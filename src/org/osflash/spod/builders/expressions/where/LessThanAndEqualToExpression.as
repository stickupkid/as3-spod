package org.osflash.spod.builders.expressions.where
{
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.builders.expressions.ISpodExpression;
	import org.osflash.spod.builders.expressions.SpodExpressionType;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.types.SpodDate;

	import flash.errors.IllegalOperationError;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class LessThanAndEqualToExpression implements ISpodExpression
	{
		
		/**
		 * @private
		 */
		private var _key : String;
		
		/**
		 * @private
		 */
		private var _value : *; 

		public function LessThanAndEqualToExpression(key : String, value : *)
		{
			if(null == key) throw new ArgumentError('Key can not be null');
			if(key.length < 1) throw new ArgumentError('Key can not be empty');
			
			_key = key;
			_value = value;
		}
		
		/**
		 * @inheritDoc
		 */
		public function build(schema : SpodTableSchema, statement : SpodStatement) : String 
		{ 
			if(null == schema) throw new ArgumentError('Schema can not be null');
			if(null == statement) throw new ArgumentError('Statement can not be null');
			
			if(schema.match(_key, _value))
			{
				if(_value is int || _value is uint || _value is Number)
				{
					statement.parameters[':' + _key] = _value;
					return '`' + _key + '` <= :' + _key;
				}
				else if(_value is Date)
				{
					const formatDate : String = SpodDate.formatToSQLiteDateTime(_value);
					return 'datetime(`' + _key + '`, \'utc\') <= datetime(\'' + 
																		formatDate + '\', \'utc\')';
				}
				else 
				{
					statement.parameters[':' + _key] = _value;
					return '`' + _key + '` <= :' + _key + ''; 
				}

			} else throw new IllegalOperationError('Invalid key');
		}
		
		/**
		 * @inheritDoc
		 */
		public function get type() : int { return SpodExpressionType.WHERE; }
	}
}
