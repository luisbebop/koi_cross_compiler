require 'rubygems'
require 'ap'

# 2 - Iterate along the array of byte codes produced by Koi Compiler function to
# generate the binary file for this VM, hints:
# - get the integer and simple:
# >> f = open('test','wb')
# => #<File:test>
# >> a =  [13].pack('i')
# => "\r\000\000\000"
# >> f <<  [13].pack('i')
# => #<File:test>
# >> f.tell
# => 4
# >> f.close
# => nil
# >> quit
# - change strings to allocate on the end of file
# - change :symbols from variables to a sequence number starting in 0

class KoiCrossCompiler
  
  def initialize
    @binary_bytecode = []
    @table_data = []
    @index_data = 0
    @table_locals = {}
    @index_locals = 0
  end
  
  def compile(bytecode, filename)
    bytecode.each do |byte|
      @binary_bytecode << [byte].pack('i') if byte.kind_of?(Integer)
      @binary_bytecode << get_variable_bytecode(byte) if byte.kind_of?(Symbol)
      @binary_bytecode << get_string_bytecode(byte) if byte.kind_of?(String)
    end
    
    ap @binary_bytecode
    ap @table_locals
    ap @table_data
    
    f = open(filename, 'wb')
    f << [@binary_bytecode.to_s.size / 4].pack('i')
    f << @binary_bytecode.to_s
    f << [@table_data.to_s.size].pack('i')
    f << @table_data.to_s
    f.close
  end
  
  def get_variable_bytecode(symbol)
    if (@table_locals[symbol]).nil?
      @table_locals[symbol] = @index_locals
      @index_locals += 1
      return [@table_locals[symbol]].pack('i')
    end
    [@table_locals[symbol]].pack('i')
  end
  
  def get_string_bytecode(string)
    original_index = @index_data
    type = "\xFF"
    size = [string.size].pack('i')[0..1]
    @table_data << type + size + string
    @index_data += (string.size + 3)
    [original_index].pack('i')
  end
  
end

# result from KoiReferenceCompiler.Compiler.compile( ast_hash )

bytecode = []

# bytecode[ 0] = 160          # PUSH_FUNCTION
# bytecode[ 1] = 8            # function_id
# bytecode[ 2] = 140          # SET_LOCAL
# bytecode[ 3] = :foo         # local name
# bytecode[ 4] = 4            # PUSH_STRING
# bytecode[ 5] = "hello world"# string
# bytecode[ 6] = 120          # PRINT
# bytecode[ 7] = 163          # RETURN
# bytecode[ 8] = 161          # END_FUNCTION
# bytecode[ 9] = 0            # ?
# bytecode[10] = 161          # END_FUNCTION
# bytecode[11] = 8            # function_id
# bytecode[12] = 140          # SET_LOCAL
# bytecode[13] = :func1       # local name
# bytecode[14] = 4            # PUSH_STRING
# bytecode[15] = "bla bla"    # string
# bytecode[16] = 141          # GET_LOCAL
# bytecode[17] = :func1       # local name
# bytecode[18] = 162           # CALL

bytecode[ 0] = 160
bytecode[ 1] = 8
bytecode[ 2] = 140
bytecode[ 3] = :foo
bytecode[ 4] = 4
bytecode[ 5] = "hello world"
bytecode[ 6] = 120
bytecode[ 7] = 141
bytecode[ 8] = :foo
bytecode[ 9] = 120
bytecode[10] = 163
bytecode[11] = 161
bytecode[12] = 0
bytecode[13] = 161
bytecode[14] = 8
bytecode[15] = 140
bytecode[16] = :func1
bytecode[17] = 4
bytecode[18] = "bla bla"
bytecode[19] = 141
bytecode[20] = :func1
bytecode[21] = 162

k = KoiCrossCompiler.new
k.compile(bytecode, "sample.out")