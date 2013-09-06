var uniqueRowId = 1;
var selectedOperatorValue = 'or';

function addTaxonFilterRow(animation) {
    animation = typeof animation !== 'undefined' ? animation : 'fast';

    // User has clicked to add another taxon row
    var lastTaxonFilterRow = $('.taxon-filter-row').last();
    // Create an element
    var el = lastTaxonFilterRow.clone(true);
    // update the ids
    uniqueRowId++;

    // data-groupid, data-grouplevel, data-groupname
    icznGroups.forEach(function(group) {
        var elementId = group.name + '_' + uniqueRowId;
        var elementName = group.name + '[' + uniqueRowId + ']';
        el.find('select[data-groupid="' + group.id + '"]').attr('id',elementId).attr('name', elementName);
    });
    el.hide();
    lastTaxonFilterRow.after(el);
    el.show(animation);
}

function addTraitFilterRow(animation) {
    animation = typeof animation !== 'undefined' ? animation : 'fast';
    // User has clicked to add another trait row
    var lastTraitFilterRow = $('.trait-filter-row').last();
    // Create an element
    var el = lastTraitFilterRow.clone(true);
    // update the ids
    uniqueRowId++;

    var traitTypeId = "trait_type_" + uniqueRowId;
    var traitNameId = "trait_name_" + uniqueRowId;
    var traitValuesId = "trait_values_" + uniqueRowId;
    var traitEntriesId = "trait_entries_" + uniqueRowId; // should only exist for continuous traits

    el.find('select.trait_type').attr('id',traitTypeId).attr('name','trait_type[' + uniqueRowId + ']');
    el.find('select.trait_name').attr('id',traitNameId).attr('name','trait_name[' + uniqueRowId + ']');
    el.find('select.trait_values').attr('id',traitValuesId).attr('name','trait_values[' + uniqueRowId + ']');
    el.find('input.trait_entries').attr('id',traitEntriesId).attr('name','trait_entries[' + uniqueRowId + ']');
    el.hide();
    lastTraitFilterRow.after(el);
    el.show(animation, function() {
        updateTraitFilterOperatorVisibility();
    });
}

function removeTaxonFilterRow(removeButton) {
    if ($(".taxon-filter-row").length > 1) {
        // Don't remove the only row
        $(removeButton).parents(".taxon-filter-row").hide('fast', function () {
            $(this).remove();
        });
    }
}

function removeTraitFilterRow(removeButton) {
    if ($(".trait-filter-row").length > 1) {
        // Don't remove the only row
        $(removeButton).parents(".trait-filter-row").hide('fast', function () {
            $(this).remove();
            updateTraitFilterOperatorVisibility();
        });
    }
}

function selectAllTraitsChanged(selectAllTraitsElement) {
    resetTraits();
    var allTraits = $(selectAllTraitsElement).is(':checked');
    // TODO: resetting traits clones the existing row so if we change them this breaks
    // TODO: need to create trait rows from scratch on reset and enable this
    $('tr.trait-filter-row select, tr.trait-filter-row input').prop('disabled', allTraits);
}

function populateInitialTraitSets() {
    // The initial trait sets <select> element is empty, and must be populated via ajax
    $.ajax({
        url: "/search/list_trait_sets.json" // no parent, get root trait set for this project
    }).done(function(data) {
            // If we somehow have more than one taxon-filter row, go ahead and update it
            var rootTraitSetSelects = $('.trait-filter-row td:nth-child(2) select.trait_set_level');
            updateTraitSets(rootTraitSetSelects, data);
        }
    );
}

function updateTraitSets(traitSetSelectElements, traitSets) {
    traitSetSelectElements.find('option').remove();
    traitSetSelectElements.each(function(i) {
        $(traitSetSelectElements[i]).append($('<option>-- Select --</option>'));
        traitSets.forEach(function(trait_set) {
            var optionElement = $('<option>', {value:trait_set.id}).text(trait_set.name);
            $(traitSetSelectElements[i]).append(optionElement);
        });
        $(traitSetSelectElements[i]).change(function() {
            traitSetChanged(this);
        });
    });
}

function traitSetChanged(traitSetSelectElement) {
    // get the level of the changed element
    var level = $(traitSetSelectElement).attr('data-trait-set-level');
    var row = $(traitSetSelectElement).attr('data-trait-filter-row');
    // get the value that was changed
    var parentTraitSetId = traitSetSelectElement.value;
    // Now call the server and ask for the trait sets with the parent
    $.ajax({
        url: "/search/list_trait_sets.json", // no parent, get root trait set for this project
        data: {'parent_trait_set_id': parentTraitSetId }
    }).done(function(data) {
            // update the child trait set if any
            var childLevel = parseInt(level, 10) + 1;
            var childTraitSetSelect = $('select.trait_set_level[data-trait-set-level=' + childLevel + '][data-trait-filter-row=' + row + ']'); // should be one element
            updateTraitSets(childTraitSetSelect, data);
        }
    );
}

function addButtonHandlers() {
    $('.add_taxon').bind('click', function() {
        addTaxonFilterRow();
    });
    $('.remove_taxon').bind('click', function() {
        removeTaxonFilterRow(this);
    });
    $('.add_trait').bind('click',function() {
        // only add traits if select all is not checked
        if(! $('#select_all_traits').is(':checked')) {
            addTraitFilterRow();
        }
    });
    $('.remove_trait').bind('click', function() {
        // only remove traits if select all is not checked
        if(! $('#select_all_traits').is(':checked')) {
            removeTraitFilterRow(this);
        }
    });
    $('#reset_search').bind('click', function() {
        resetSearchForm();
    });
    $('#select_all_traits').bind('change', function() {
        selectAllTraitsChanged(this);
    });
}

function updateCategoricalTraitNames(traitTypeElement, traitList) {
    // find the trait names select element
    var traitElement = $(traitTypeElement).closest(".trait-filter-row").find(".trait_name");
    // remove all options from the select
    traitElement.find('option').remove();
    traitElement.append($('<option value>-- Select --</option>'));
    for(var trait in traitList) {
        var obj = traitList[trait];
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        traitElement.append(optionElement);
    }
}

function updateContinuousTraitNames(traitTypeElement, traitList) {
    // find the trait names select element
    var traitElement = $(traitTypeElement).closest(".trait-filter-row").find(".trait_name");
    // remove all options from the select
    traitElement.find('option').remove();
    traitElement.append($('<option value>-- Select --</option>'));
    for(var trait in traitList) {
        var obj = traitList[trait];
        // now make a new select option and append it
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        traitElement.append(optionElement);
    }
}

function updateContinuousTraitValuePredicates(traitElement) {
    var traitValuesElement = $(traitElement).closest(".trait-filter-row").find(".trait_values");
    traitValuesElement.find('option').remove();
    traitValuesElement.append($('<option value>-- All Values --</option>'));
    traitValuesElement.append($('<option value="eq">= (Equals)</option>'));
    traitValuesElement.append($('<option value="ne">!= (Does not equal)</option>'));
    traitValuesElement.append($('<option value="gt">&gt; (Is greater than)</option>'));
    traitValuesElement.append($('<option value="lt">&lt; (Is less than)</option>'));
    updateContinuousTraitEntries(traitValuesElement);
}

function updateContinuousTraitEntries(traitValuesElement) {
    if (traitValuesElement.value == 'in') {
        // show the second field
        // would be good to resize too
        $(traitValuesElement).closest(".trait-filter-row").find('.trait_entries').children('.field2').show();
    } else {
        // hide the second field
        $(traitValuesElement).closest(".trait-filter-row").find('.trait_entries').children('.field2').hide();
    }
}

function updateCategoricalTraitValues(traitElement, valueList) {
    // find the trait values select element
    var traitValuesElement = $(traitElement).closest(".trait-filter-row").find('.trait_values');
    // remove all options from the select
    traitValuesElement.find('option').remove();
    traitValuesElement.append($('<option value>-- Select --</option>'));
    for(var traitValue in valueList) {
        var obj = valueList[traitValue];
        var optionElement = $('<option>', {value: obj.id}).text(obj.name);
        traitValuesElement.append(optionElement);
    }
}

function groupChanged(groupElement, groupId) {
    // when a group changes, reload the possible values for everything that is more specific
    var level = parseInt(groupElement.attributes['data-grouplevel'].value, 10);
    var groupLevelsToSend = icznGroups.map(function(g) { return g.level; }).filter(function(l) { return l <= level; });
    var parentIds = new Array();
    groupLevelsToSend.forEach(function(groupLevel) {
        parentIds.push($(groupElement).closest(".taxon-filter-row").find('select[data-grouplevel=' + groupLevel + ']').val());
    });
    console.log('parentIds' + parentIds);
    // Send an ajax request for each of the group levels to clear
    var groupsToClear = icznGroups.filter(function(g) { return g.level > level; });
    groupsToClear.forEach(function(group) {
        $(groupElement).closest(".taxon-filter-row").find('select[data-grouplevel=' + group.level + ']').find('option').remove();
        $.ajax({
            url: "/search/list_taxa.json",
            data: {
                iczn_group_id: group.id,
                parent_ids: parentIds
            }
        }).done(function(data) {
                var specificGroupElement = $(groupElement).closest(".taxon-filter-row").find('select[data-grouplevel=' + group.level + ']').first();
                updateGroupList(specificGroupElement, data);
                console.log('received response from list taxa for group id : ' + group.id + ' data: ' + data);
            }
        );
    });
}

function updateGroupList(destinationSelectElement, taxa) {
    // remove all options from the element
    destinationSelectElement.find('option').remove();
    destinationSelectElement.append($('<option value>-- All --</option>'));
    taxa.forEach(function(taxon) {
        var optionElement = $('<option>', {value:taxon.id}).text(taxon.name);
        destinationSelectElement.append(optionElement);
        });
}

function getIndex(element) {
    var index = $(element).attr('id').lastIndexOf('_') + 1;
    return $(element).attr('id').substring(index);
}

// need an update trait types
function traitTypeChanged(traitTypeElement, traitTypeId) {
    // When getting traits, need to supply the selected taxonomy
    var selectedTaxonIds = jQuery.map($('#taxa').find('select'), function(e, i) { return $(e).val(); }).filter( function(e, i) { return e.length > 0; });
    // TODO: support levels
    $(traitTypeElement).closest(".trait-filter-row").find(".trait_name").find('option').remove();
    $(traitTypeElement).closest(".trait-filter-row").find(".trait_values").find('option').remove();
    var traitNameElement = $(traitTypeElement).closest(".trait-filter-row").find(".trait_name").first();
    if(traitTypeElement.value == 'continuous') {
        if($(traitTypeElement).closest(".trait-filter-row").find(".trait_entries").length === 0) {
            // no trait_entries element, create one
            var traitEntriesElement = $('<input></input>');
            traitEntriesElement.addClass('trait_entries input-medium');
            traitEntriesElement.attr('type', 'number');
            traitEntriesElement.attr('id', 'trait_entries_' + getIndex(traitTypeElement));
            traitEntriesElement.attr('name','trait_entries[' + getIndex(traitTypeElement) + ']');
            var traitEntriesCell = $('<td></td>');
            $(traitEntriesCell).append(traitEntriesElement);
            // have the cell, append it to the table
            $(traitTypeElement).closest(".trait-filter-row").find(".trait_values").parent().after(traitEntriesCell);
        }
        $.ajax({
            url: "/search/list_continuous_trait_names.json",
            data: {
                taxon_ids: selectedTaxonIds
            }
        }).done(function(data, textstatus, jqXHR) {
                updateContinuousTraitNames(traitTypeElement, data);
                traitNameElement.change(function(){
                    continuousTraitNameChanged(this, this.value);
                });
            });
    } else {
        if($(traitTypeElement).closest(".trait-filter-row").find(".trait_entries").length > 0) {
            // have a trait entries, remove its parent
            $(traitTypeElement).closest(".trait-filter-row").find(".trait_entries").parent().remove();
        }
      $.ajax({
            url: "/search/list_categorical_trait_names.json",
            data: {
                taxon_ids: selectedTaxonIds
            }
        }).done(function(data, textstatus, jqXHR) {
              updateCategoricalTraitNames(traitTypeElement, data);
              traitNameElement.change(function(){
                  categoricalTraitNameChanged(this, this.value);
              });
          });
    }
}

function categoricalTraitNameChanged(categoricalTraitNameElement, traitId) {
    $(categoricalTraitNameElement).closest(".trait-filter-row").find(".trait_values").find('option').remove();
    $.ajax({
        url: "/search/list_categorical_trait_values.js",
        data: { trait_id: traitId }
    }).done(function(data, textstatus, jqXHR) { updateCategoricalTraitValues(categoricalTraitNameElement, data); });
}

function continuousTraitNameChanged(continuousTraitNameElement, traitId) {
    updateContinuousTraitValuePredicates(continuousTraitNameElement);
}

function addSelectionChangeListeners() {
    // taxonomy
    $('select[data-groupid]').change(function() {
        groupChanged(this,this.value);
    });
    // trait
    $('select.trait_type').change(function() {
        traitTypeChanged(this,this.value);
    });
}

function resetTaxonomy() {
    var taxon_row_count = $('.taxon-filter-row').length;
    addTaxonFilterRow(0); // animation speed
    $('form')[0].reset();
    for(var i=0; i < taxon_row_count; i++) {
        $('.taxon-filter-row').first().remove();
    }
    return false;
}

function resetTraits() {
    var trait_row_count = $('.trait-filter-row').length;
    addTraitFilterRow(0); // animation speed
    for(var i=0; i < trait_row_count; i++) {
        $('.trait-filter-row').first().remove();
    }
    updateTraitFilterOperatorVisibility();
    return false;
}

function resetSearchForm() {
    resetTaxonomy();
    resetTraits();
    return false;
}

function updateTraitFilterOperatorVisibility() {
    // trait_operator should only be in the last row and only
    // if there are more than one traits

    var trait_row_count = $('.trait-filter-row').length;
    $('.trait_operator').remove();
    if(trait_row_count > 1) {
        // insert a new element
        var operatorElement = $('<select id="trait_operator" name="trait_operator"></select>');
        operatorElement.addClass("trait_operator").addClass("span12");
        operatorElement.append($('<option value="or">OR</option>'));
        operatorElement.append($('<option value="and">AND</option>'));
        operatorElement[0].value = selectedOperatorValue;
        operatorElement.change(function() {
            selectedOperatorValue = this.value;
        });
        $('.trait-filter-row').last().find(".operator_placeholder").first().append(operatorElement);
    }
    return false;
}