require 'spec_helper'
require 'yaml'
require "#{LKP_SRC}/lib/hash"

expects = [
  ['create path',
   '{}',
   '1.2.3: 4',
   { '1' => { '2' => { '3' => 4 } } }],
  ['add scalar to scalar',
   'a.b.c: 1',
   'a.b.c+: 2',
   { 'a' => { 'b' => { 'c' => [1, 2] } } }],
  ['add scalar to array',
   'a.b.c: [1, 2]',
   'a.b.c+: 3',
   { 'a' => { 'b' => { 'c' => [1, 2, 3] } } }],
  ['add duplicate scalar to array',
   'a.b.c: [1, 2]',
   'a.b.c+: 2',
   { 'a' => { 'b' => { 'c' => [1, 2] } } }],
  ['add scalar to hash',
   'a.b.c: {1: 2}',
   'a.b.c+: 3',
   { 'a' => { 'b' => { 'c' => { 1 => 2, 3 => nil } } } }],
  ['add array to array',
   'a.b.c: [1, 2]',
   'a.b.c+: [3]',
   { 'a' => { 'b' => { 'c' => [1, 2, 3] } } }],
  ['add hash to hash',
   'a.b.c: {1: 2}',
   'a.b.c+: {3: 4}',
   { 'a' => { 'b' => { 'c' => { 1 => 2, 3 => 4 } } } }],
  ['add array to scalar',
   'a.b.c: 1',
   'a.b.c+: [2, 3]',
   { 'a' => { 'b' => { 'c' => [1, 2, 3] } } }],
  ['add hash to scalar',
   'a.b.c: 1',
   'a.b.c+: {2: 3}',
   { 'a' => { 'b' => { 'c' => { 1 => nil, 2 => 3 } } } }],
  ['delete array item',
   'a.b.c: [1, 2]',
   'a.b.c-: 1',
   { 'a' => { 'b' => { 'c' => [2] } } }],
  ['delete array items',
   'a.b.c: [1, 2, 3]',
   'a.b.c-: [1, 2]',
   { 'a' => { 'b' => { 'c' => [3] } } }],
  ['delete hash item',
   'a.b.c: {1: 2, 3: 4}',
   'a.b.c-: 1',
   { 'a' => { 'b' => { 'c' => { 3 => 4 } } } }],
  ['delete hash items',
   'a.b.c: {1: 2, 3: 4}',
   'a.b.c-: [1, 3]',
   { 'a' => { 'b' => { 'c' => nil } } }],
  ['delete last array',
   'a.b.c: [1, 2]',
   'a.b.c-: ',
   { 'a' => { 'b' => nil } }],
  ['delete last hash',
   'a.b.c: {1: 2, 3: 4}',
   'a.b.c-: ',
   { 'a' => { 'b' => nil } }],
  ['delete mid hash',
   'a.b.c: {1: 2, 3: 4}',
   'a.b-: ',
   { 'a' => nil }],
  ['delete top hash',
   'a.b.c: {1: 2, 3: 4}',
   'a-: ',
   {}],

  ['normal hash merge',
   "a:\n  b: 1\nc: 2",
   "a:\n  b: [3, 4]\nd: 5",
   { 'a' => { 'b' => [3, 4] }, 'c' => 2, 'd' => 5 }],
  ['accumulative key',
   'mail_cc: XXX',
   'mail_cc: YYY',
   { 'mail_cc' => %w(XXX YYY) }],
  ['double add array',
   'a+: 1',
   'a+: [2, 3]',
   { 'a' => [1, 2, 3] }],
  ['double add hash',
   'a+: 1',
   'a+: {2: 3}',
   { 'a' => { 1 => nil, 2 => 3 } }],
  ['double delete array',
   "a: [1, 2, 3]\na-: 1",
   'a-: [2]',
   { 'a' => [3] }],
  ['double delete hash',
   "a: {b: 1, c: 2, d: 3}\na-: b",
   'a-: [c]',
   { 'a' => { 'd' => 3 } }],

  # deal with abnormal cases gracefully
  ['empty + empty',
   '',
   '',
   {}],
  ['empty + create path',
   '',
   'a.b.c: 1',
   { 'a' => { 'b' => { 'c' => 1 } } }],
  ['empty + nil',
   '',
   '---',
   {}],
  ['nil + empty',
   '---',
   '',
   {}],
  ['nil + create path',
   '---',
   'a.b.c: 1',
   { 'a' => { 'b' => { 'c' => 1 } } }],
  ['nil + nil',
   '---',
   '---',
   {}]
]

describe 'hash lookup/revise' do
  expects.each do |e|
    it e[0] do
      expect(revise_hash(revise_hash({}, YAML.load(e[1])), YAML.load(e[2]))).to eq e[3]
      expect(revise_hash(YAML.load(e[1]), YAML.load(e[2]))).to eq e[3]
    end
  end
end

describe 'lookup_hash' do
  let(:hash) { { 'a' => { 'b' => { 'c' => 1 } } } }

  it 'finds existing key' do
    _parent, _pkey, h, key, keys = lookup_hash(hash, 'a.b.c')
    expect(h[key]).to eq 1
    expect(keys).to be_empty
  end

  it 'returns partial path for missing key' do
    _parent, _pkey, h, key, keys = lookup_hash(hash, 'a.b.d')
    expect(h).to eq({ 'c' => 1 })
    expect(key).to eq 'd'
    expect(keys).to be_empty
  end

  it 'creates missing keys if requested' do
    _parent, _pkey, _h, key, _keys = lookup_hash(hash, 'a.x.y', create_missing: true)
    expect(hash['a']['x']).to be_a(Hash)
    expect(key).to eq 'y'
  end
end

describe 'merge_accumulative' do
  it 'concatenates arrays' do
    expect(merge_accumulative([1], [2])).to eq [1, 2]
  end

  it 'merges hashes' do
    expect(merge_accumulative({ a: 1 }, { b: 2 })).to eq({ a: 1, b: 2 })
  end

  it 'converts scalar to array when merging with array' do
    expect(merge_accumulative(1, [2])).to eq [1, 2]
  end
end

describe 'handle_minus_key' do
  it 'deletes a key' do
    hash = { 'a' => 1, 'b' => 2 }
    handle_minus_key(hash, 'a-', nil)
    expect(hash).to eq({ 'b' => 2 })
  end

  it 'deletes specific values from array' do
    hash = { 'a' => [1, 2, 3] }
    handle_minus_key(hash, 'a-', 2)
    expect(hash).to eq({ 'a' => [1, 3] })
  end

  it 'deletes nested key' do
    hash = { 'a' => { 'b' => 1 } }
    handle_minus_key(hash, 'a.b-', nil)
    expect(hash).to eq({ 'a' => nil })
  end
end
