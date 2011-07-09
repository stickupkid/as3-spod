package org.osflash.spod.builders
{
	import org.osflash.spod.spod_namespace;
	import org.osflash.spod.SpodIndexTable;
	import org.osflash.spod.SpodStatement;
	import org.osflash.spod.schema.ISpodSchema;
	import org.osflash.spod.schema.SpodTableColumnSchema;
	import org.osflash.spod.schema.SpodTableSchema;
	import org.osflash.spod.types.SpodTypes;

	import flash.errors.IllegalOperationError;
	import flash.utils.getQualifiedClassName;
	/**
	 * @author Simon Richardson - me@simonrichardson.info
	 */
	public class CreateIndexStatementBuilder implements ISpodStatementBuilder
	{
		
		/**
		 * @private
		 */
		private var _schema : ISpodSchema;
		
		/**
		 * @private
		 */
		private var _buffer : Vector.<String>;
		
		/**
		 * @private
		 */
		private var _ignoreIfExists : Boolean;
		
		public function CreateIndexStatementBuilder(schema : ISpodSchema)
		{
			if(null == schema) throw new ArgumentError('Schema can not be null');
			_schema = schema;
			
			_buffer = new Vector.<String>();
			_ignoreIfExists = true; // TODO : make sure we can inject this.
		}
		
		/**
		 * @inheritDoc
		 */
		public function build() : SpodStatement
		{
			if(_schema is SpodTableSchema)
			{
				const tableSchema : SpodTableSchema = SpodTableSchema(_schema);
				const columns : Vector.<SpodTableColumnSchema> = tableSchema.columns.reverse();
				const total : int = columns.length;
				
				if(total == 0) throw new IllegalOperationError('Invalid columns length');
				
				_buffer.length = 0;
				
				_buffer.push('CREATE UNIQUE INDEX ');
				
				if(_ignoreIfExists) _buffer.push('IF NOT EXISTS ');
				
				for(var i : int = 0; i<total; i++)
				{
					const column : SpodTableColumnSchema = columns[i];
					
					if(column.name == 'id' && column.type == SpodTypes.INT)
					{
						use namespace spod_namespace;
						const indexName : String = SpodIndexTable.PREFIX + column.name;
						
						_buffer.push('`' + indexName + '` ');
						_buffer.push('ON ');
						_buffer.push('`' + _schema.name + '` ');
						_buffer.push('(');
						_buffer.push('`' + column.name + '` ');
						_buffer.push(')');
					}
				}
						
				const statement : SpodStatement = new SpodStatement(tableSchema.type);
				statement.query = _buffer.join('');
				
				return statement;
				
			} else throw new ArgumentError(getQualifiedClassName(_schema) + ' is not supported');
		}
	}
}
