import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const SimulatorApp());
}

class SimulatorApp extends StatelessWidget {
  const SimulatorApp({super.key});

  // Paleta de Cores da Empresa
  static const Color primaryOrange = Color(0xFFDA8939);
  static const Color lightOrange = Color(0xFFF2BA66);
  static const Color beigeBackground = Color(0xFFE7DCCF);
  static const Color goldenOrange = Color(0xFFEDA639);
  static const Color terracottaRed = Color(0xFFDE5038);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador de Custos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryOrange,
          primary: primaryOrange,
          secondary: terracottaRed,
          tertiary: goldenOrange,
          surface: beigeBackground,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: beigeBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryOrange),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: primaryOrange, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700),
        ),
      ),
      home: const SimulatorScreen(),
    );
  }
}

// --- Models ---

class CostItem {
  String id;
  String name;
  double value;
  IconData icon;
  bool isActive;

  CostItem({
    required this.id,
    required this.name,
    required this.value,
    required this.icon,
    this.isActive = true,
  });
}

// --- Main Screen ---

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  // Controllers
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _studentsController = TextEditingController();
  final TextEditingController _simulationController = TextEditingController();

  // State
  bool _isNegotiationMode = false;
  int _studentCount = 0;
  double _simulatedPrice = 0.0;
  
  // Data
  final List<CostItem> _costs = [
    CostItem(id: '1', name: 'Material Didático', value: 120.00, icon: Icons.menu_book),
    CostItem(id: '2', name: 'Plataforma Digital', value: 45.00, icon: Icons.computer),
    CostItem(id: '3', name: 'Suporte Pedagógico', value: 15.00, icon: Icons.support_agent),
  ];

  // Constants
  final double _minProfitPerStudent = 1.00;

  // Colors from Palette
  final Color _primaryOrange = const Color(0xFFDA8939);
  final Color _terracottaRed = const Color(0xFFDE5038);
  final Color _goldenOrange = const Color(0xFFEDA639);
  final Color _lightOrange = const Color(0xFFF2BA66);

  @override
  void initState() {
    super.initState();
    _studentsController.addListener(_updateCalculations);
    _simulationController.addListener(_updateSimulation);
  }

  @override
  void dispose() {
    _schoolNameController.dispose();
    _studentsController.dispose();
    _simulationController.dispose();
    super.dispose();
  }

  void _updateCalculations() {
    setState(() {
      _studentCount = int.tryParse(_studentsController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    });
  }

  void _updateSimulation() {
    setState(() {
      // Simple parsing for demo. In production, use a currency formatter for input.
      String text = _simulationController.text.replaceAll(',', '.');
      _simulatedPrice = double.tryParse(text) ?? 0.0;
    });
  }

  // Logic
  double get _totalCostPerStudent {
    return _costs
        .where((c) => c.isActive)
        .fold(0.0, (sum, item) => sum + item.value);
  }

  double get _minPricePerStudent => _totalCostPerStudent + _minProfitPerStudent;
  
  double get _totalProjectValue => _simulatedPrice * _studentCount;
  
  double get _totalMinProfit => _studentCount * _minProfitPerStudent;

  bool get _isPriceValid => _simulatedPrice >= _minPricePerStudent;

  // Actions
  void _toggleCost(int index) {
    setState(() {
      _costs[index].isActive = !_costs[index].isActive;
    });
  }

  void _removeCost(int index) {
    setState(() {
      _costs.removeAt(index);
    });
  }

  void _addNewCost() {
    showDialog(
      context: context,
      builder: (context) => AddCostDialog(onAdd: (item) {
        setState(() {
          _costs.add(item);
        });
      }),
    );
  }

  void _editCost(int index) {
     showDialog(
      context: context,
      builder: (context) => AddCostDialog(
        existingItem: _costs[index],
        onAdd: (item) {
          setState(() {
            _costs[index] = item;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de Fechamento', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          Switch(
            value: _isNegotiationMode,
            activeColor: _goldenOrange,
            activeTrackColor: Colors.white,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.black12,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            onChanged: (val) {
              setState(() {
                _isNegotiationMode = val;
              });
            },
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0, left: 8.0),
            child: Center(child: Text("Modo Negociação", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          )
        ],
      ),
      body: Column(
        children: [
          // Header Section (School Info)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _schoolNameController,
                    decoration: InputDecoration(
                      labelText: 'Nome da Escola',
                      prefixIcon: Icon(Icons.school, color: _primaryOrange),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _studentsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Nº Alunos',
                      prefixIcon: Icon(Icons.people, color: _primaryOrange),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Costs List (Hidden in Negotiation Mode)
                if (!_isNegotiationMode)
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Composição de Custos (por aluno)",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown.shade700
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _addNewCost,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Adicionar"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _goldenOrange,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _costs.length,
                              itemBuilder: (context, index) {
                                final cost = _costs[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: cost.isActive 
                                          ? _lightOrange.withOpacity(0.3) 
                                          : Colors.grey.shade200,
                                      child: Icon(cost.icon, color: cost.isActive ? _primaryOrange : Colors.grey),
                                    ),
                                    title: Text(
                                      cost.name,
                                      style: TextStyle(
                                        decoration: cost.isActive ? null : TextDecoration.lineThrough,
                                        color: cost.isActive ? Colors.black87 : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(currencyFormat.format(cost.value)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Switch(
                                          value: cost.isActive,
                                          activeColor: _primaryOrange,
                                          onChanged: (val) => _toggleCost(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          color: Colors.grey.shade600,
                                          onPressed: () => _editCost(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 20),
                                          color: _terracottaRed,
                                          onPressed: () => _removeCost(index),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Divider(),
                          _buildSummaryRow("Custo Total / Aluno:", _totalCostPerStudent, currencyFormat, isBold: true),
                          _buildSummaryRow("Lucro Mínimo Obrigatório:", _minProfitPerStudent, currencyFormat, color: Colors.green.shade700),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _lightOrange.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _goldenOrange),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("PREÇO MÍNIMO PERMITIDO:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown.shade800)),
                                Text(
                                  currencyFormat.format(_minPricePerStudent),
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.brown.shade800),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Right Column: Simulation & Closing (Always Visible)
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Simulação de Fechamento",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _primaryOrange,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        
                        // Simulation Input
                        Text("Preço Proposto por Aluno", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _simulationController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            prefixText: 'R\$ ',
                            filled: true,
                            fillColor: _isPriceValid ? Colors.green.shade50 : _terracottaRed.withOpacity(0.1),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: _isPriceValid ? Colors.green : _terracottaRed,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: _isPriceValid ? Colors.green : _terracottaRed,
                                width: 2,
                              ),
                            ),
                            suffixIcon: _isPriceValid 
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : Icon(Icons.block, color: _terracottaRed),
                          ),
                        ),
                        
                        if (!_isPriceValid && _simulationController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Valor abaixo do mínimo permitido (${currencyFormat.format(_minPricePerStudent)})",
                              style: TextStyle(color: _terracottaRed, fontWeight: FontWeight.bold),
                            ),
                          ),

                        const SizedBox(height: 32),
                        const Divider(),
                        const SizedBox(height: 16),

                        // Final Numbers
                        _buildBigStat("Valor Total do Projeto", _totalProjectValue, currencyFormat, isValid: _isPriceValid),
                        const SizedBox(height: 16),
                        if (!_isNegotiationMode) ...[
                          _buildBigStat("Lucro Total Estimado", (_simulatedPrice - _totalCostPerStudent) * _studentCount, currencyFormat, isSecondary: true),
                          const SizedBox(height: 8),
                          Text(
                            "Lucro Mínimo Garantido: ${currencyFormat.format(_totalMinProfit)}",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        const Spacer(),
                        
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isPriceValid && _studentCount > 0 ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Proposta validada e pronta para contrato!'), backgroundColor: Colors.green),
                              );
                            } : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isPriceValid ? _terracottaRed : Colors.grey,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            child: const Text("GERAR PROPOSTA"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, NumberFormat format, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
          Text(format.format(value), style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }

  Widget _buildBigStat(String label, double value, NumberFormat format, {bool isValid = true, bool isSecondary = false}) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        Text(
          format.format(value),
          style: TextStyle(
            fontSize: isSecondary ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: isValid ? (isSecondary ? _primaryOrange : Colors.black87) : _terracottaRed,
          ),
        ),
      ],
    );
  }
}

// --- Dialog for Adding/Editing Costs ---

class AddCostDialog extends StatefulWidget {
  final Function(CostItem) onAdd;
  final CostItem? existingItem;

  const AddCostDialog({super.key, required this.onAdd, this.existingItem});

  @override
  State<AddCostDialog> createState() => _AddCostDialogState();
}

class _AddCostDialogState extends State<AddCostDialog> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  IconData _selectedIcon = Icons.monetization_on;

  // Colors
  final Color _primaryOrange = const Color(0xFFDA8939);
  final Color _lightOrange = const Color(0xFFF2BA66);

  final List<IconData> _availableIcons = [
    Icons.menu_book, Icons.computer, Icons.support_agent, Icons.directions_bus,
    Icons.restaurant, Icons.sports_soccer, Icons.science, Icons.music_note,
    Icons.build, Icons.security, Icons.wifi, Icons.print,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      _nameController.text = widget.existingItem!.name;
      _valueController.text = widget.existingItem!.value.toStringAsFixed(2);
      _selectedIcon = widget.existingItem!.icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingItem == null ? 'Adicionar Custo' : 'Editar Custo', style: TextStyle(color: _primaryOrange, fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome do Custo'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Valor (R\$)'),
            ),
            const SizedBox(height: 16),
            const Text("Ícone:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableIcons.map((icon) {
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _selectedIcon == icon ? _lightOrange.withOpacity(0.5) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: _selectedIcon == icon ? Border.all(color: _primaryOrange, width: 2) : null,
                    ),
                    child: Icon(icon, color: _selectedIcon == icon ? _primaryOrange : Colors.grey),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Cancelar', style: TextStyle(color: Colors.grey))
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text;
            final value = double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0.0;
            if (name.isNotEmpty && value > 0) {
              widget.onAdd(CostItem(
                id: widget.existingItem?.id ?? DateTime.now().toString(),
                name: name,
                value: value,
                icon: _selectedIcon,
                isActive: widget.existingItem?.isActive ?? true,
              ));
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: _primaryOrange),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
