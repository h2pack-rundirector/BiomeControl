local lu = require("luaunit")

TestBiomeControlLogic = {}

function TestBiomeControlLogic:testPatchPlanAppliesAndRevertsRoomAndNpcMutations()
    local harness = ResetBiomeControlHarness({
        config = {
            ModeStoryArachne = 2,
            PackedStoryArachneMin = 5,
            PackedStoryArachneMax = 7,
            ModeMiniBossTreant = 1,
            NPCSpacing = 9,
            PreventEchoScam = true,
        },
    })

    local okApply, applyErr = harness.liveHost.applyMutation()
    lu.assertTrue(okApply, tostring(applyErr))

    lu.assertEquals(RoomData.F_Story01.ForceAtBiomeDepthMin, 5)
    lu.assertEquals(RoomData.F_Story01.ForceAtBiomeDepthMax, 7)
    lu.assertEquals(RoomData.F_Story01.GameStateRequirements[1].Value, 5)
    lu.assertEquals(RoomData.F_Story01.GameStateRequirements[2].Value, 7)
    lu.assertEquals(#RoomData.F_MiniBoss01.GameStateRequirements, 1)
    lu.assertEquals(RoomData.F_MiniBoss01.GameStateRequirements[1].Value, -1)
    lu.assertEquals(NamedRequirementsData.NoRecentFieldNPCEncounter[1].SumPrevRooms, 9)
    lu.assertEquals(#RoomData.H_MiniBoss01.GameStateRequirements, 1)
    lu.assertEquals(RoomData.H_MiniBoss01.GameStateRequirements[1].Value, 3)

    local okRevert, revertErr = harness.liveHost.revertMutation()
    lu.assertTrue(okRevert, tostring(revertErr))

    lu.assertNil(RoomData.F_Story01.ForceAtBiomeDepthMin)
    lu.assertNil(RoomData.F_Story01.ForceAtBiomeDepthMax)
    lu.assertEquals(RoomData.F_Story01.GameStateRequirements[1].Value, 4)
    lu.assertEquals(RoomData.F_Story01.GameStateRequirements[2].Value, 8)
    lu.assertEquals(#RoomData.F_MiniBoss01.GameStateRequirements, 0)
    lu.assertEquals(NamedRequirementsData.NoRecentFieldNPCEncounter[1].SumPrevRooms, 6)
    lu.assertEquals(#RoomData.H_MiniBoss01.GameStateRequirements, 0)
end

function TestBiomeControlLogic:testForcedErebusTrialInjectsDevotionReward()
    local harness = ResetBiomeControlHarness({
        config = {
            ModeTrialErebus = 2,
            PackedTrialErebusMin = 7,
            PackedTrialErebusMax = 9,
        },
        RoomSetData = {
            F = {
                F_Combat05 = { Name = "F_Combat05" },
            },
        },
    })

    local okApply, applyErr = harness.liveHost.applyMutation()
    lu.assertTrue(okApply, tostring(applyErr))

    lu.assertEquals(RoomSetData.F.F_Combat05.ForcedReward, "Devotion")
    lu.assertEquals(RoomSetData.F.F_Combat05.ForceAtBiomeDepthMin, 7)
    lu.assertEquals(RoomSetData.F.F_Combat05.ForceAtBiomeDepthMax, 9)
end

function TestBiomeControlLogic:testForcedOceanusTrialInjectsDevotionReward()
    local harness = ResetBiomeControlHarness({
        config = {
            ModeTrialOceanus = 2,
            PackedTrialOceanusMin = 4,
            PackedTrialOceanusMax = 6,
        },
        RoomSetData = {
            G = {
                G_Combat02 = { Name = "G_Combat02" },
            },
        },
    })

    local okApply, applyErr = harness.liveHost.applyMutation()
    lu.assertTrue(okApply, tostring(applyErr))

    lu.assertEquals(RoomSetData.G.G_Combat02.ForcedReward, "Devotion")
    lu.assertEquals(RoomSetData.G.G_Combat02.ForceAtBiomeDepthMin, 4)
    lu.assertEquals(RoomSetData.G.G_Combat02.ForceAtBiomeDepthMax, 6)
end

function TestBiomeControlLogic:testBiomePriorityFiltersEligibleLootUntilSatisfied()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
            PrioritizeSpecificRewardEnabled = true,
            PriorityBiome1 = "ApolloUpgrade",
        },
        CurrentRun = {
            ClearedBiomes = 0,
        },
        GetEligibleLootNames = function()
            return { "ZeusUpgrade", "ApolloUpgrade" }
        end,
    })

    lu.assertEquals(GetEligibleLootNames({}), { "ApolloUpgrade" })

    GiveLoot({ ForceLootName = "ApolloUpgrade" })
    lu.assertEquals(GetEligibleLootNames({}), { "ZeusUpgrade", "ApolloUpgrade" })
end

function TestBiomeControlLogic:testBiomePriorityIgnoresGodPoolDisabledChoice()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
            PrioritizeSpecificRewardEnabled = true,
            PriorityBiome1 = "ApolloUpgrade",
        },
        godAvailability = {
            available = {
                Apollo = false,
            },
        },
        CurrentRun = {
            ClearedBiomes = 0,
        },
        GetEligibleLootNames = function()
            return { "ZeusUpgrade", "ApolloUpgrade" }
        end,
    })

    lu.assertEquals(GetEligibleLootNames({}), { "ZeusUpgrade", "ApolloUpgrade" })
end

function TestBiomeControlLogic:testTrialRewardPrioritySetsEncounterLootPair()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
            PrioritizeTrialRewardEnabled = true,
            PriorityTrial1 = "ApolloUpgrade",
            PriorityTrial2 = "ZeusUpgrade",
        },
        CurrentRun = {},
        GetInteractedGodsThisRun = function()
            return { "ApolloUpgrade", "ZeusUpgrade" }
        end,
        GetEligibleLootNames = function(excluded)
            if excluded and excluded[1] == "ApolloUpgrade" then
                return { "ZeusUpgrade" }
            end
            return { "ApolloUpgrade", "ZeusUpgrade" }
        end,
    })

    local room = {
        ChosenRewardType = "Devotion",
        Encounter = {},
    }
    SetupRoomReward(CurrentRun, room, nil, {})

    lu.assertEquals(room.Encounter.LootAName, "ApolloUpgrade")
    lu.assertEquals(room.Encounter.LootBName, "ZeusUpgrade")
end

function TestBiomeControlLogic:testTrialRewardPrioritySkipsGodPoolDisabledChoice()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
            PrioritizeTrialRewardEnabled = true,
            PriorityTrial1 = "ApolloUpgrade",
            PriorityTrial2 = "ZeusUpgrade",
        },
        godAvailability = {
            available = {
                Apollo = false,
            },
        },
        CurrentRun = {},
        GetInteractedGodsThisRun = function()
            return { "ApolloUpgrade", "ZeusUpgrade" }
        end,
        GetEligibleLootNames = function(excluded)
            if excluded and excluded[1] == "ApolloUpgrade" then
                return { "ZeusUpgrade" }
            end
            return { "ApolloUpgrade", "ZeusUpgrade" }
        end,
    })

    local room = {
        ChosenRewardType = "Devotion",
        Encounter = {},
    }
    SetupRoomReward(CurrentRun, room, nil, {})

    lu.assertNil(room.Encounter.LootAName)
    lu.assertNil(room.Encounter.LootBName)
end

function TestBiomeControlLogic:testForcedNpcEncounterNarrowsLegalEncounterList()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
            ModeNPCArtemisErebus = 2,
            PackedNPCArtemisErebusMin = 4,
            PackedNPCArtemisErebusMax = 10,
        },
        CurrentRun = {},
        ChooseEncounter = function(_, _, args)
            return args.LegalEncounters
        end,
    })

    local currentRun = {
        BiomeDepthCache = 4,
    }
    local room = {
        RoomSetName = "F",
        LegalEncounters = {
            "NemesisCombatF",
            "ArtemisCombatF",
        },
    }
    local result = ChooseEncounter(currentRun, room, {})

    lu.assertEquals(result, { "ArtemisCombatF" })
end

function TestBiomeControlLogic:testOnlyAllowForcedEncountersFiltersUnforcedNpcEncounters()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
            OnlyAllowForcedEncounters = true,
        },
        CurrentRun = {},
        ChooseEncounter = function(_, _, args)
            return args.LegalEncounters
        end,
    })

    local currentRun = {
        BiomeDepthCache = 4,
    }
    local room = {
        RoomSetName = "F",
        LegalEncounters = {
            "NemesisCombatF",
            "ArtemisCombatF",
            "GenericCombatF",
        },
    }
    local result = ChooseEncounter(currentRun, room, {})

    lu.assertEquals(result, { "GenericCombatF" })
end

function TestBiomeControlLogic:testFieldsTwoRewardHookOverridesEarlyCombatRooms()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
            ForceTwoRewardFieldsOpeners = true,
        },
    })

    local result = SelectFieldsDoorCageCount({
        BiomeDepthCache = 2,
    }, {
        Name = "H_Combat01",
        MinDoorCageRewards = 2,
    })

    lu.assertEquals(result, 2)
end

function TestBiomeControlLogic:testEphyraLogicReplacesHermesAndFiltersSubroomRewards()
    local harness = ResetBiomeControlHarness({
        config = {
            ReplaceHermesInEphyra = "ApolloUpgrade",
            PackedBannedEphyraSubRoomRewards = bit32.lshift(1, 0),
            PackedBannedEphyraSubRoomRewardsHard = bit32.lshift(1, 2),
        },
        RewardStoreData = {
            HubRewards = {
                { Name = "HermesUpgrade", GameStateRequirements = { "remove me" } },
            },
            SubRoomRewards = {
                { Name = "MaxManaDropSmall" },
                { Name = "GiftDrop" },
            },
            SubRoomRewardsHard = {
                { Name = "StackUpgrade" },
                { Name = "Money" },
            },
        },
        CurrentRun = {},
        EncounterData = {
            BaseArtemisCombat = {},
        },
    })

    local okApply, applyErr = harness.liveHost.applyMutation()
    lu.assertTrue(okApply, tostring(applyErr))

    lu.assertEquals(RewardStoreData.HubRewards[1].Name, "ApolloUpgrade")
    lu.assertNil(RewardStoreData.HubRewards[1].GameStateRequirements)
    lu.assertEquals(RewardStoreData.SubRoomRewards, {
        { Name = "GiftDrop" },
    })
    lu.assertEquals(RewardStoreData.SubRoomRewardsHard, {
        { Name = "Money" },
    })
    lu.assertEquals(EncounterData.BaseArtemisCombat.RequireNotRoomReward, { "ApolloUpgrade" })
end

function TestBiomeControlLogic:testThessalyLogicForcesSelectedMiniboss()
    local harness = ResetBiomeControlHarness({
        config = {
            ThessalyMiniBossMode = 1,
            PackedForcedThessalyMiniBossMin = 3,
            PackedForcedThessalyMiniBossMax = 5,
        },
        RoomData = {
            O_MiniBoss01 = {
                Name = "O_MiniBoss01",
                GameStateRequirements = {
                    { Path = { "CurrentRun", "BiomeDepthCache" }, Comparison = ">=", Value = 2 },
                    { Path = { "CurrentRun", "BiomeDepthCache" }, Comparison = "<=", Value = 4 },
                },
            },
            O_MiniBoss02 = {
                Name = "O_MiniBoss02",
                GameStateRequirements = {},
            },
        },
    })

    local okApply, applyErr = harness.liveHost.applyMutation()
    lu.assertTrue(okApply, tostring(applyErr))

    lu.assertTrue(RoomData.O_MiniBoss01.AlwaysForce)
    lu.assertEquals(RoomData.O_MiniBoss01.ForceAtBiomeDepthMin, 3)
    lu.assertEquals(RoomData.O_MiniBoss01.ForceAtBiomeDepthMax, 5)
    lu.assertEquals(RoomData.O_MiniBoss01.GameStateRequirements[1].Value, 3)
    lu.assertEquals(RoomData.O_MiniBoss01.GameStateRequirements[2].Value, 5)
    lu.assertEquals(RoomData.O_MiniBoss02.GameStateRequirements[1].Value, -1)
end

function TestBiomeControlLogic:testDreamRouteSetsNextRoomSetAndPool()
    ResetBiomeControlHarness({
        registerHooks = true,
        config = {
            Enabled = true,
            DreamRouteEnabled = true,
            DreamRouteBiome1 = "G",
            DreamRouteBiome2 = "I",
            DreamRouteBiome3 = "N",
            DreamRouteBiome4 = "P",
        },
        CurrentRun = {
            IsDreamRun = true,
            EnteredBiomes = 0,
            CurrentRoom = {},
        },
        GameState = {},
    })

    SelectNextDreamBiome(nil)

    lu.assertEquals(CurrentRun.CurrentRoom.NextRoomSet, { "G" })
    lu.assertEquals(CurrentRun.DreamBiomePool, { "I", "N", "P" })
    lu.assertEquals(GameState.LastDreamStartingBiome, "G")
end
