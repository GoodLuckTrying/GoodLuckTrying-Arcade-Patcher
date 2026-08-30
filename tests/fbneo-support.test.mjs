import test from 'node:test';
import assert from 'node:assert/strict';
import { isDirectFbNeoSupported } from '../assets/js/patcher-app.js';

test('Ghouls Artoria supports every build directly in FB Neo', () => {
  assert.equal(isDirectFbNeoSupported('ghouls-artoria-v10', { sourceRomset: 'ghouls', label: 'Ghouls Maiden Artoria Edition (World)' }), true);
  assert.equal(isDirectFbNeoSupported('ghouls-artoria-v10', { sourceRomset: 'daimakai', label: 'Daimakaimura Knight Artoria Edition' }), true);
});

test('GNG Artoria only marks the direct gng/makaimur maiden and knight patches', () => {
  assert.equal(isDirectFbNeoSupported('gng-artoria-v12', { sourceRomset: 'gng', label: 'Ghosts\'n Goblins - Maiden Artoria Edition (World)' }), true);
  assert.equal(isDirectFbNeoSupported('gng-artoria-v12', { sourceRomset: 'makaimur', label: 'Makaimura - Knight Artoria Edition' }), true);
  assert.equal(isDirectFbNeoSupported('gng-artoria-v12', { sourceRomset: 'gnga', label: 'Ghosts\'n Goblins - Maiden Artoria Edition (World set 2)' }), false);
  assert.equal(isDirectFbNeoSupported('gng-artoria-v12', { sourceRomset: 'gng', label: 'Ghosts\'n Goblins - Maiden Artoria Edition Enhanced' }), false);
});

test('GNG Enhanced only marks direct gng/makaimur based builds', () => {
  assert.equal(isDirectFbNeoSupported('gng-enhanced-v10', { sourceRomset: 'gng', label: 'Ghosts\'n Goblins Enhanced' }), true);
  assert.equal(isDirectFbNeoSupported('gng-enhanced-v10', { sourceRomset: 'makaimur', label: 'Makaimura Enhanced' }), true);
  assert.equal(isDirectFbNeoSupported('gng-enhanced-v10', { sourceRomset: 'gngb', label: 'GNGB Enhanced' }), false);
});
