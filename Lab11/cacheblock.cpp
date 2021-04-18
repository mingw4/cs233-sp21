#include "cacheblock.h"

uint32_t Cache::Block::get_address() const {
  // TODO
  //_cache_config

  uint32_t index_bits = _cache_config.get_num_index_bits();
  uint32_t offset_bits = _cache_config.get_num_block_offset_bits();
  uint32_t tag = get_tag(); // tage is 0 here, but for guarantee, still move right
  return ((tag << index_bits) + _index) << offset_bits;
}
