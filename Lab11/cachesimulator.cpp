#include "cachesimulator.h"
#include <algorithm>
using std::uint32_t;
using std::vector;

Cache::Block* CacheSimulator::find_block(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `_cache->get_blocks_in_set` to get all the blocks that could
   *    possibly have `address` cached.
   * 2. Loop through all these blocks to see if any one of them actually has
   *    `address` cached (i.e. the block is valid and the tags match).
   * 3. If you find the block, increment `_hits` and return a pointer to the
   *    block. Otherwise, return NULL.
   */
  uint32_t index = extract_index(address,_cache->get_config());
  vector<Cache::Block*> possible_blocks = _cache->get_blocks_in_set(index); // step 1

  uint32_t tag = extract_tag(address,_cache->get_config()); 
  for (auto& it : possible_blocks) { // step 2
    if (it->get_tag() == tag && it->is_valid()) { 
      _hits++;
      return it; //step 3
    } 
  }
  return NULL;
}

Cache::Block* CacheSimulator::bring_block_into_cache(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `_cache->get_blocks_in_set` to get all the blocks that could
   *    cache `address`.
   * 2. Loop through all these blocks to find an invalid `block`. If found,
   *    skip to step 4.
   * 3. Loop through all these blocks to find the least recently used `block`.
   *    If the block is dirty, write it back to memory.
   * 4. Update the `block`'s tag. Read data into it from memory. Mark it as
   *    valid. Mark it as clean. Return a pointer to the `block`.
   */
  uint32_t index = extract_index(address, _cache->get_config());
  vector<Cache::Block*> possible_blocks = _cache->get_blocks_in_set(index); // finish step 1

  uint32_t tag = extract_tag(address, _cache->get_config()); 
  
  //vector<uint32_t> time_list;
  Cache::Block* least_used = possible_blocks[0];
  for (auto& it : possible_blocks) {
    // step 2
    if (!(it->is_valid())) { 
      it->set_tag(tag); // Update the `block`'s tag.
      it->read_data_from_memory(_memory); // Read data into it from memory.
      it->mark_as_valid(); // Mark it as valid.
      it->mark_as_clean(); // Mark it as clean.
      return it;
    }
    //time_list.push_back(it->get_last_used_time());
    // step 3
    if (it->get_last_used_time() < least_used->get_last_used_time()){
      least_used = it;
    }
  }
  //uint32_t least_used = max_element();

  // step 3
  if (least_used->is_dirty()) {
    least_used->write_data_to_memory(_memory);
  }

  least_used->set_tag(tag); // Update the `block`'s tag.
  least_used->read_data_from_memory(_memory); // Read data into it from memory.
  least_used->mark_as_valid(); // Mark it as valid.
  least_used->mark_as_clean(); // Mark it as clean.
  return least_used;
}

uint32_t CacheSimulator::read_access(uint32_t address) const {
  /**
   * TODO
   *
   * 1. Use `find_block` to find the `block` caching `address`.
   * 2. If not found, use `bring_block_into_cache` cache `address` in `block`.
   * 3. Update the `last_used_time` for the `block`.
   * 4. Use `read_word_at_offset` to return the data at `address`.
   */
  Cache::Block* caching_block = find_block(address); // step 1

  if (!caching_block){
    caching_block = bring_block_into_cache(address); // step 2
  }

  _use_clock++;
  caching_block->set_last_used_time(_use_clock.get_count()); // step 3

  uint32_t block_offset = extract_block_offset(address, _cache->get_config());
  return caching_block->read_word_at_offset(block_offset);
}

void CacheSimulator::write_access(uint32_t address, uint32_t word) const {
  /**
   * TODO
   *
   * 1. Use `find_block` to find the `block` caching `address`.
   * 2. If not found
   *    a. If the policy is write allocate, use `bring_block_into_cache`.
   *    a. Otherwise, directly write the `word` to `address` in the memory
   *       using `_memory->write_word` and return.
   * 3. Update the `last_used_time` for the `block`.
   * 4. Use `write_word_at_offset` to to write `word` to `address`.
   * 5. a. If the policy is write back, mark `block` as dirty.
   *    b. Otherwise, write `word` to `address` in memory.
   */

  Cache::Block* caching_block = find_block(address); // step 1

  if (!caching_block){
    if (_policy.is_write_allocate()) {
      caching_block = bring_block_into_cache(address); // step 2.a
    } else {
      _memory->write_word(address, word); // step 2.b
      return;
    }
  }
  _use_clock++;
  caching_block->set_last_used_time(_use_clock.get_count()); // step 3

  uint32_t block_offset = extract_block_offset(address, _cache->get_config());
  caching_block->write_word_at_offset(word, block_offset); // step 4
  if (_policy.is_write_back()){
    caching_block->mark_as_dirty(); // step 5.a
  } else {
    caching_block->write_data_to_memory(_memory); // step 5.b
  }

}
