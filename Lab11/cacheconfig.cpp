#include "cacheconfig.h"
#include "utils.h"
#include <math.h>
using std::uint32_t;
CacheConfig::CacheConfig(uint32_t size, uint32_t block_size, uint32_t associativity)
: _size(size), _block_size(block_size), _associativity(associativity) {
  /**
   * TODO
   * Compute and set `_num_block_offset_bits`, `_num_index_bits`, `_num_tag_bits`.
  */ 
  uint32_t set_num = 0;
  if (block_size != 0 && associativity != 0){
    set_num = uint32_t(size / block_size) / associativity;
  }
  _num_block_offset_bits = log2(block_size);
  _num_index_bits = log2(set_num);
  _num_tag_bits = 32 - _num_block_offset_bits - _num_index_bits;
}
