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
    var categoricalTraitNameId = "categorical_trait_name_" + uniqueRowId;
    var categoricalTraitValuesId = "categorical_trait_values_" + uniqueRowId;
    var continuousTraitNameId = "continuous_trait_name_" + uniqueRowId;
    var continuousTraitValuePredicatesId = "continuous_trait_value_predicates_" + uniqueRowId;
    var continuousTraitEntriesId = "continous_trait_entries_" + uniqueRowId;

    el.find('select.trait_type').attr('id',traitTypeId).attr('name','trait_type[' + uniqueRowId + ']');
    el.find('select.categorical_trait_name').attr('id',categoricalTraitNameId).attr('name','categorical_trait_name[' + uniqueRowId + ']');
    el.find('select.categorical_trait_values').attr('id',categoricalTraitValuesId).attr('name','categorical_trait_values[' + uniqueRowId + ']');
    el.find('select.continuous_trait_name').attr('id',continuousTraitNameId).attr('name','continuous_trait_name[' + uniqueRowId + ']');
    el.find('select.continuous_trait_value_predicates').attr('id',continuousTraitValuePredicatesId).attr('name','continuous_trait_value_predicates[' + uniqueRowId + ']');
    el.find('input.continuous_trait_entries').attr('id',continuousTraitEntriesId).attr('name','continuous_trait_entries[' + uniqueRowId + ']');
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

function addButtonHandlers() {
    $('.add_taxon').bind('click', function() {
        addTaxonFilterRow();
    });
    $('.remove_taxon').bind('click', function() {
        removeTaxonFilterRow(this);
    });
    $('.add_trait').bind('click',function() {
        addTraitFilterRow();
    });
    $('.remove_trait').bind('click', function() {
        removeTraitFilterRow(this);
    });
    $('#reset_search').bind('click', function() {
        resetSearchForm();
    });
}

function updateCategoricalTraitNames(traitTypeElement, traitList) {
    // find the trait names select element
    var traitElement = $(traitTypeElement).siblings(".categorical_trait_name");
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
    var traitElement = $(traitTypeElement).siblings(".continuous_trait_name");
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
    var traitValuesElement = $(traitElement).siblings(".continuous_trait_value_predicates");
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
        $(traitValuesElement).siblings('.continuous_trait_entries').children('.field2').show();
    } else {
        // hide the second field
        $(traitValuesElement).siblings('.continuous_trait_entries').children('.field2').hide();
    }
}

function updateCategoricalTraitValues(traitElement, valueList) {
    // find the trait values select element
    var traitValuesElement = $(traitElement).siblings(".categorical_trait_values");
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
    var level = parseInt(groupElement.attributes['data-grouplevel'].value);
    var groupLevelsToSend = icznGroups.map(function(g) { return g.level; }).filter(function(l) { return l <= level});
    var parentIds = new Array($(groupElement).val());
    groupLevelsToSend.forEach(function(groupLevel) {
        parentIds.push($(groupElement).siblings('select[data-grouplevel=' + groupLevel + ']').val());
    });
    console.log('parentIds' + parentIds);
    // Send an ajax request for each of the group levels to clear
    var groupsToClear = icznGroups.filter(function(g) { return g.level > level; });
    groupsToClear.forEach(function(group) {
        $(groupElement).siblings('select[data-grouplevel=' + group.level + ']').find('option').remove();
        $.ajax({
            url: "/search/list_taxa.json",
            data: {
                iczn_group_id: group.id,
                parent_ids: parentIds
            }
        }).done(function(data) {
                var specificGroupElement = $(groupElement).siblings('select[data-grouplevel=' + group.level + ']').first()
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

// need an update trait types
function traitTypeChanged(traitTypeElement, traitTypeId) {
    if(traitTypeElement.value == 'continuous') {
        $(traitTypeElement).siblings(".continuous_trait_name").find('option').remove();
        $(traitTypeElement).siblings(".continuous_trait_name, .continuous_trait_value_predicates, .continuous_trait_entries").show('fast');
        $(traitTypeElement).siblings(".categorical_trait_name, .categorical_trait_values").hide('fast');
        $.ajax({
            url: "/search/list_continuous_trait_names.json"
        }).done(function(data, textstatus, jqXHR) { updateContinuousTraitNames(traitTypeElement, data); });
    } else {
        $(traitTypeElement).siblings(".categorical_trait_name").find('option').remove();
        $(traitTypeElement).siblings(".continuous_trait_name, .continuous_trait_value_predicates, .continuous_trait_entries").hide('fast');
        $(traitTypeElement).siblings(".categorical_trait_name, .categorical_trait_values").show('fast');
        $.ajax({
            url: "/search/list_categorical_trait_names.json"
        }).done(function(data, textstatus, jqXHR) { updateCategoricalTraitNames(traitTypeElement, data); });
    }

}

function categoricalTraitNameChanged(categoricalTraitNameElement, traitId) {
    $(categoricalTraitNameElement).siblings(".categorical_trait_values").find('option').remove();
    $.ajax({
        url: "/search/list_categorical_trait_values.js",
        data: { trait_id: traitId }
    }).done(function(data, textstatus, jqXHR) { updateCategoricalTraitValues(categoricalTraitNameElement, data); });
}

function continuousTraitNameChanged(continuousTraitNameElement, traitId) {
    updateContinuousTraitValuePredicates(continuousTraitNameElement);
}

function continuousTraitValuePredicateChanged(continuousTraitValuePredicateElement, predicateId) {

}

function continuousTraitEntryChanged(continuousTraitEntryElement, entryId) {

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
    $('select.categorical_trait_name').change(function() {
        categoricalTraitNameChanged(this,this.value);
    });
    $('select.continuous_trait_name').change(function() {
        continuousTraitNameChanged(this,this.value);
    });
    $('select.continuous_trait_value_predicates').change(function() {
        continuousTraitValuePredicateChanged(this,this.value);
    });
    $('input.continuous_trait_entries').change(function() {
        continuousTraitEntryChanged(this,this.value);
    });

}

function hideContinuousFields() {
    $('select.continuous_trait_name').hide();
    $('select.continuous_trait_value_predicates').hide();
    $('input.continuous_trait_entries').hide();
}

function resetSearchForm() {
    var taxon_row_count = $('.taxon-filter-row').length;
    var trait_row_count = $('.trait-filter-row').length;

    addTaxonFilterRow(0); // animation speed
    addTraitFilterRow(0); // animation speed
    $('form')[0].reset();

    for(var i=0; i < taxon_row_count; i++) {
        $('.taxon-filter-row').first().remove();
    }
    for(var i=0; i < trait_row_count; i++) {
        $('.trait-filter-row').first().remove();
    }
    updateTraitFilterOperatorVisibility();
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