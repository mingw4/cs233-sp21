#include "utils.h"
#include <iostream>
using std::uint32_t;
using namespace std;
uint32_t extract_tag(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  uint32_t tag_bits = cache_config.get_num_tag_bits();
  //cout<<tag_bits<<endl;
  // if (tag_bits >= 32){
  //   return address
  // }
  return address >> (32 - tag_bits);
}

uint32_t extract_index(uint32_t address, const CacheConfig& cache_config) {
  uint32_t tag_bits = cache_config.get_num_tag_bits();
  uint32_t offset_bits = cache_config.get_num_block_offset_bits();
  //cout<<tag_bits<<endl;
  if (tag_bits >= 32){
    return 0;
  }
  return (address << tag_bits) >> (tag_bits + offset_bits);
}

uint32_t extract_block_offset(uint32_t address, const CacheConfig& cache_config) {
  uint32_t tag_bits = cache_config.get_num_tag_bits();
  uint32_t offset_bits = cache_config.get_num_block_offset_bits();
  //cout<<tag_bits<<endl;
  if (tag_bits >= 32){
    return 0;
  }
  return (address << (32 - offset_bits)) >> (32 - offset_bits);
}
